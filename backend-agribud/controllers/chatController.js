// controllers/chatController.js
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/db');
const faqModel = require('../models/faqModel');
const Groq = require('groq-sdk');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// --- KONFIGURASI KEDUA AI ---
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const groqModel = 'llama3-8b-8192';
const geminiModel = genAI.getGenerativeModel({ model: "gemini-1.5-pro-latest" });

const SYSTEM_PROMPT = "Kamu adalah AgriBot...";

// --- FUNGSI HELPER  ---
const getChatHistory = async (conversationId) => {
  // ... (kode getChatHistory tidak berubah)
  const [messages] = await pool.query('SELECT role, content FROM messages WHERE conversation_id = ? ORDER BY created_at ASC', [conversationId]);
  return messages.map(msg => ({
    role: msg.role,
    content: msg.content
  }));
};

const generateChatTitle = async (firstMessage) => {
    // ... (kode generateChatTitle tidak berubah, tetap pakai Groq karena cepat)
    try {
        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: 'user', content: `Buat judul singkat (maksimal 5 kata) untuk percakapan yang diawali dengan pesan ini: "${firstMessage}"` }],
            model: groqModel,
        });
        return chatCompletion.choices[0]?.message?.content.trim() || firstMessage.substring(0, 50);
    } catch (error) {
        console.error("Error generating title with Groq, using default.", error);
        return firstMessage.substring(0, 50);
    }
}

const findFaqMatch = async (userQuestion) => {
  // ... (kode findFaqMatch tidak berubah)
  try {
    const faqs = await faqModel.getAllFaqs();
    if (faqs.length === 0) return null;
    const stopWords = new Set(['apa', 'bagaimana', 'kapan', 'kenapa', 'mengapa', 'dimana', 'siapa', 'itu', 'ini', 'adalah', 'cara', 'dan', 'atau', 'di', 'ke', 'dari', 'untuk', 'dengan', 'yang', 'saya']);
    const userKeywords = userQuestion.toLowerCase().replace(/[^\w\s]/gi, '').split(/\s+/).filter(word => word.length > 2 && !stopWords.has(word));
    if (userKeywords.length === 0) return null;
    let bestMatch = null;
    let highestScore = 0;
    faqs.forEach(faq => {
      const faqKeywords = new Set((faq.keywords || '').toLowerCase().split(',').map(k => k.trim()));
      let currentScore = 0;
      userKeywords.forEach(userWord => {
        if (faqKeywords.has(userWord)) {
          currentScore++;
        }
      });
      if (currentScore > highestScore) {
        highestScore = currentScore;
        bestMatch = faq;
      }
    });
    if (highestScore >= 2) {
      console.log(`INFO: FAQ Match Found by Keywords! Score: ${highestScore}. Serving answer from DB.`);
      return bestMatch.answer;
    }
    return null;
  } catch (error) {
    console.error("Error during FAQ keyword check:", error);
    return null;
  }
};

// --- CONTROLLER LOGIC ---

const handleChatLogic = async (message, userId, conversationId = null, userFile) => {
  const connection = await pool.getConnection();
  await connection.beginTransaction();
  
  try {
    let modelResponse;
    let currentConversationId = conversationId;

    if (userFile) {
      // --- JIKA ADA FILE, GUNAKAN GEMINI ---
      console.log("INFO: File detected. Calling Gemini API.");
      const history = conversationId ? (await getChatHistory(conversationId)).map(m => ({ role: m.role, parts: [{ text: m.content }] })) : [];
      const chat = geminiModel.startChat({ history });
      const promptParts = [
        message || "Tolong analisis file ini dari sudut pandang pertanian.",
        { inlineData: { data: userFile.buffer.toString("base64"), mimeType: userFile.mimetype } }
      ];
      const result = await chat.sendMessage(promptParts);
      modelResponse = result.response.text();
    } else {
      // --- JIKA HANYA TEKS, GUNAKAN FAQ ATAU GROQ ---
      modelResponse = await findFaqMatch(message);
      if (!modelResponse) {
        console.log("INFO: No FAQ match. Calling Groq API.");
        const history = conversationId ? (await getChatHistory(conversationId)).map(m => ({ role: m.role === 'model' ? 'assistant' : 'user', content: m.content })) : [];
        const messages = [{ role: 'system', content: SYSTEM_PROMPT }, ...history, { role: 'user', content: message }];
        const chatCompletion = await groq.chat.completions.create({ messages, model: groqModel });
        modelResponse = chatCompletion.choices[0]?.message?.content;
      }
    }

    // Proses penyimpanan ke DB (tidak berubah)
    if (!conversationId) {
      currentConversationId = uuidv4();
      const title = await generateChatTitle(message || "Percakapan dengan file");
      await connection.query('INSERT INTO conversations (id, user_id, title) VALUES (?, ?, ?)', [currentConversationId, userId, title]);
    }
    await connection.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?)', [currentConversationId, 'user', message || `[File: ${userFile.originalname}]`]);
    await connection.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?)', [currentConversationId, 'model', modelResponse]);
    await connection.commit();
    
    return { conversationId: currentConversationId, reply: modelResponse };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

// --- EXPORTS (Tidak ada perubahan signifikan, hanya memanggil handleChatLogic) ---

exports.startNewChat = async (req, res) => {
  try {
    const { message, userId } = req.body;
    if (!message && !req.file) {
      return res.status(400).json({ error: 'message or file is required.' });
    }
    const result = await handleChatLogic(message, userId, null, req.file);
    res.status(201).json({
      message: "New conversation started.",
      conversationId: result.conversationId,
      reply: result.reply
    });
  } catch (error) {
    console.error('Error starting new chat:', error);
    res.status(500).json({ error: 'Failed to handle chat request.' });
  }
};

exports.continueChat = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { message, userId } = req.body;
    if (!message && !req.file) {
      return res.status(400).json({ error: 'message or file is required.' });
    }
     if (!userId) {
      return res.status(400).json({ error: 'userId is required for context.' });
    }
    const result = await handleChatLogic(message, userId, conversationId, req.file);
    res.status(200).json({ reply: result.reply });
  } catch (error) {
    console.error('Error continuing chat:', error);
    res.status(500).json({ error: 'Failed to handle chat request.' });
  }
};

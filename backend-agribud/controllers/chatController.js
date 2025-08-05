// controllers/chatController.js
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/db');
const faqModel = require('../models/faqModel');

// --- KONFIGURASI GEMINI ---
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const systemInstruction = "Kamu adalah AgriBot, asisten AI ahli dari aplikasi Agribuddy. Misi utamamu adalah membantu petani, mahasiswa agrikultur, dan masyarakat umum di Indonesia. Aturan Penting: 1. Fokus Topik: Jawab HANYA pertanyaan yang berhubungan dengan pertanian, perkebunan, agribisnis, tanaman pangan, hortikultura, hama & penyakit tanaman, pupuk, kesuburan tanah, irigasi, dan topik agrikultur terkait lainnya. 2. Tolak Pertanyaan di Luar Topik: Jika ada pertanyaan di luar topik (misalnya tentang politik, film, atau matematika), TOLAK dengan sopan. Contoh: 'Maaf, sebagai AgriBot, saya hanya bisa membantu dengan pertanyaan seputar dunia pertanian.' 3. Bahasa Sederhana: Gunakan bahasa Indonesia yang jelas, sederhana, dan mudah dipahami oleh petani atau orang awam. Hindari istilah teknis yang rumit. 4. Jawaban Ringkas & Padat: Berikan jawaban yang langsung ke inti, tidak bertele-tele, namun tetap mencakup poin-poin penting. Gunakan daftar bernomor atau poin-poin jika memungkinkan untuk mempermudah pembacaan.";

const model = genAI.getGenerativeModel({
  model: "gemini-1.5-pro-latest",
  systemInstruction: systemInstruction,
});

// --- FUNGSI HELPER ---
const getChatHistory = async (conversationId) => {
  const [messages] = await pool.query('SELECT role, content FROM messages WHERE conversation_id = ? ORDER BY created_at ASC', [conversationId]);
  return messages.map(msg => ({ role: msg.role, parts: [{ text: msg.content }] }));
};

const generateChatTitle = async (firstMessage) => {
    const titleGenModel = genAI.getGenerativeModel({ model: "gemini-pro" });
    const prompt = `Buat judul singkat (maksimal 5 kata) untuk percakapan yang diawali dengan pesan ini: "${firstMessage}"`;
    try {
        const result = await titleGenModel.generateContent(prompt);
        return result.response.text().trim();
    } catch (error) {
        console.error("Error generating title, using default.", error);
        return firstMessage.substring(0, 50); // Fallback
    }
}

/**
 * FUNGSI BARU: Mencari jawaban di FAQ menggunakan AI
 * @param {string} userQuestion Pertanyaan dari user
 * @returns {string|null} Jawaban dari FAQ jika cocok, atau null jika tidak.
 */
const findFaqMatch = async (userQuestion) => {
  try {
    const faqs = await faqModel.getAllFaqs();
    if (faqs.length === 0) return null;

    // Buat daftar pertanyaan FAQ untuk dikirim ke Gemini
    const faqListForPrompt = faqs.map(faq => `ID: ${faq.id} - Pertanyaan: "${faq.question}"`).join('\n');

    const prompt = `
      Anda adalah asisten klasifikasi. Tugas Anda adalah menentukan apakah pertanyaan pengguna memiliki maksud yang SAMA dengan salah satu pertanyaan dalam daftar FAQ berikut.
      
      Daftar FAQ:
      ${faqListForPrompt}

      Pertanyaan Pengguna: "${userQuestion}"

      Jika ada yang cocok, balas HANYA dengan ID dari FAQ yang cocok (contoh: "12"). Jika sama sekali tidak ada yang cocok, balas HANYA dengan kata "null".
    `;

    // Kita gunakan model yang lebih cepat/murah untuk klasifikasi ini
    const classificationModel = genAI.getGenerativeModel({ model: "gemini-pro" });
    const result = await classificationModel.generateContent(prompt);
    const responseText = result.response.text().trim();

    if (responseText !== 'null' && !isNaN(responseText)) {
      const matchedId = parseInt(responseText, 10);
      const matchedFaq = faqs.find(faq => faq.id === matchedId);
      if (matchedFaq) {
        console.log(`INFO: FAQ Match Found! ID: ${matchedId}. Serving answer from DB.`);
        return matchedFaq.answer; // Kembalikan jawaban dari database
      }
    }
    
    return null; // Tidak ada yang cocok
  } catch (error) {
    console.error("Error during FAQ check:", error);
    return null; // Jika ada error, anggap saja tidak ada yang cocok dan lanjutkan ke Gemini utama
  }
};


// --- CONTROLLER LOGIC ---

const handleChatLogic = async (message, userId, conversationId = null, userFile) => {
  // LOGIKA BARU: Cek FAQ dulu
  // Kita hanya cek FAQ jika tidak ada file yang di-upload
  let modelResponse = null;
  if (!userFile) {
    modelResponse = await findFaqMatch(message);
  }

  const connection = await pool.getConnection();
  await connection.beginTransaction();

  try {
    let currentConversationId = conversationId;

    // Jika jawaban tidak ditemukan di FAQ, panggil Gemini
    if (!modelResponse) {
      console.log("INFO: No FAQ match. Calling Gemini API.");
      const history = conversationId ? await getChatHistory(conversationId) : [];
      const chat = model.startChat({ history });
      const promptParts = [message];
      if (userFile) {
        promptParts.push({ inlineData: { data: userFile.buffer.toString("base64"), mimeType: userFile.mimetype } });
      }
      const result = await chat.sendMessage(promptParts);
      modelResponse = result.response.text();
    }

    // Proses penyimpanan ke DB
    if (!conversationId) { // Ini adalah chat baru
      currentConversationId = uuidv4();
      const title = await generateChatTitle(message);
      await connection.query('INSERT INTO conversations (id, user_id, title) VALUES (?, ?, ?)', [currentConversationId, userId, title]);
    }

    await connection.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?)', [currentConversationId, 'user', message]);
    await connection.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?)', [currentConversationId, 'model', modelResponse]);
    
    await connection.commit();
    
    return {
        conversationId: currentConversationId,
        reply: modelResponse
    };

  } catch (error) {
    await connection.rollback();
    throw error; // Lemparkan error untuk ditangani oleh pemanggil
  } finally {
    connection.release();
  }
};

exports.startNewChat = async (req, res) => {
  try {
    const { message, userId } = req.body;
    if (!message || !userId) {
      return res.status(400).json({ error: 'message and userId are required.' });
    }
    const result = await handleChatLogic(message, userId, null, req.file);
    res.status(201).json({
      message: "New conversation started.",
      conversationId: result.conversationId,
      reply: result.reply
    });
  } catch (error) {
    console.error('Error starting new chat:', error);
    if (error.message && error.message.includes('429')) {
        return res.status(429).json({ error: 'Kuota percakapan sudah habis :( Mohon tunggu sejenak dan coba lagi :D' });
    }
    res.status(500).json({ error: 'Failed to handle chat request.' });
  }
};

exports.continueChat = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { message } = req.body;
    if (!message) {
      return res.status(400).json({ error: 'message is required.' });
    }
    // Untuk melanjutkan chat, kita butuh userId. Frontend harus mengirimkannya.
    // Atau kita bisa ambil dari token JWT, tapi untuk sekarang kita minta dari body.
    const { userId } = req.body; 
    if (!userId) {
      return res.status(400).json({ error: 'userId is required for context.' });
    }

    const result = await handleChatLogic(message, userId, conversationId, req.file);
    res.status(200).json({
      reply: result.reply
    });
  } catch (error) {
    console.error('Error continuing chat:', error);
    if (error.message && error.message.includes('429')) {
        return res.status(429).json({ error: 'Kuota percakapan sudah habis :( Mohon tunggu sejenak dan coba lagi :D' });
    }
    res.status(500).json({ error: 'Failed to handle chat request.' });
  }
};
// controllers/chatController.js
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { v4: uuidv4 } = require('uuid');
const db = require('../config/db'); // Menggunakan pool promise

// --- KONFIGURASI GEMINI ---
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const systemInstruction = "Kamu adalah AgriBot, asisten AI ahli dari aplikasi Agribuddy. Misi utamamu adalah membantu petani, mahasiswa agrikultur, dan masyarakat umum di Indonesia. Aturan Penting: 1. Fokus Topik: Jawab HANYA pertanyaan yang berhubungan dengan pertanian, perkebunan, agribisnis, tanaman pangan, hortikultura, hama & penyakit tanaman, pupuk, kesuburan tanah, irigasi, dan topik agrikultur terkait lainnya. 2. Tolak Pertanyaan di Luar Topik: Jika ada pertanyaan di luar topik (misalnya tentang politik, film, atau matematika), TOLAK dengan sopan. Contoh: 'Maaf, sebagai AgriBot, saya hanya bisa membantu dengan pertanyaan seputar dunia pertanian.' 3. Bahasa Sederhana: Gunakan bahasa Indonesia yang jelas, sederhana, dan mudah dipahami oleh petani atau orang awam. Hindari istilah teknis yang rumit. 4. Jawaban Ringkas & Padat: Berikan jawaban yang langsung ke inti, tidak bertele-tele, namun tetap mencakup poin-poin penting. Gunakan daftar bernomor atau poin-poin jika memungkinkan untuk mempermudah pembacaan.";

const model = genAI.getGenerativeModel({
  model: "gemini-1.5-pro-latest",
  systemInstruction: systemInstruction,
});

// --- FUNGSI HELPER ---
const getChatHistory = async (conversationId) => {
  const [messages] = await db.query('SELECT role, content FROM messages WHERE conversation_id = ? ORDER BY created_at ASC', [conversationId]);
  return messages.map(msg => ({
    role: msg.role,
    parts: [{ text: msg.content }]
  }));
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

// --- CONTROLLER LOGIC ---

/**
 * Memulai percakapan baru.
 */
exports.startNewChat = async (req, res) => {
  try {
    const { message, userId } = req.body;
    if (!message || !userId) {
      return res.status(400).json({ error: 'message and userId are required.' });
    }

    const conversationId = uuidv4();
    const title = await generateChatTitle(message);
    const userFile = req.file;

    // Memulai sesi chat di Gemini (tanpa history)
    const chat = model.startChat({ history: [] });

    // Membuat prompt, bisa berisi teks dan file
    const promptParts = [message];
    if (userFile) {
      promptParts.push({ inlineData: { data: userFile.buffer.toString("base64"), mimeType: userFile.mimetype } });
    }

    // Mengirim pesan pertama ke Gemini
    const result = await chat.sendMessage(promptParts);
    const modelResponse = result.response.text();

    // Simpan semua ke database dalam satu transaksi
    const connection = await db.getConnection();
    await connection.beginTransaction();
    try {
        await connection.query('INSERT INTO conversations (id, user_id, title) VALUES (?, ?, ?)', [conversationId, userId, title]);
        await connection.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?)', [conversationId, 'user', message]);
        await connection.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?)', [conversationId, 'model', modelResponse]);
        await connection.commit();
    } catch(dbError) {
        await connection.rollback();
        throw dbError; // Lemparkan error untuk ditangkap oleh catch utama
    } finally {
        connection.release();
    }

    res.status(201).json({
      message: "New conversation started.",
      conversationId: conversationId,
      reply: modelResponse
    });

  } catch (error) {
    console.error('Error starting new chat:', error);
    if (error.message && error.message.includes('429')) {
        return res.status(429).json({ error: 'Kuota percakapan sudah habis :( Mohon tunggu sejenak dan coba lagi :D' });
    }
    res.status(500).json({ error: 'Failed to communicate with the AI model.' });
  }
};


/**
 * Melanjutkan percakapan yang sudah ada.
 */
exports.continueChat = async (req, res) => {
    try {
        const { conversationId } = req.params;
        const { message } = req.body;
        if (!message) {
            return res.status(400).json({ error: 'message is required.' });
        }

        const userFile = req.file;
        const history = await getChatHistory(conversationId);

        // Memulai sesi chat dengan history yang sudah ada
        const chat = model.startChat({ history });

        // Membuat prompt, bisa berisi teks dan file
        const promptParts = [message];
        if (userFile) {
            promptParts.push({ inlineData: { data: userFile.buffer.toString("base64"), mimeType: userFile.mimetype } });
        }
        
        // Mengirim pesan lanjutan ke Gemini
        const result = await chat.sendMessage(promptParts);
        const modelResponse = result.response.text();

        // Simpan pesan user dan balasan model ke database
        await db.query('INSERT INTO messages (conversation_id, role, content) VALUES (?, ?, ?), (?, ?, ?)', [
            conversationId, 'user', message,
            conversationId, 'model', modelResponse
        ]);

        res.status(200).json({
            reply: modelResponse
        });

    } catch (error) {
        console.error('Error continuing chat:', error);
        if (error.message && error.message.includes('429')) {
            return res.status(429).json({ error: 'Kuota percakapan sudah habis :( Mohon tunggu sejenak dan coba lagi :D' });
        }
        res.status(500).json({ error: 'Failed to communicate with the AI model.' });
    }
};
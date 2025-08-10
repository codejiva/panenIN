const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const upload = require('../middleware/upload');

// --- Routes untuk Mengelola Percakapan ---
// GET: Mendapatkan semua daftar percakapan milik seorang user
router.get('/user/:userId', chatController.getUserConversations);

// GET: Mendapatkan semua pesan di dalam satu percakapan spesifik
router.get('/:conversationId/messages', chatController.getConversationMessages);

// DELETE: Menghapus satu percakapan
router.delete('/:conversationId', chatController.deleteConversation);


// --- Routes untuk Berinteraksi dengan AI ---
// POST: Memulai percakapan baru
router.post('/start', upload.single('file'), chatController.startNewChat);

// POST: Melanjutkan percakapan yang sudah ada
router.post('/:conversationId/message', upload.single('file'), chatController.continueChat);

module.exports = router;
// routes/chatRoute.js
const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const upload = require('../middleware/upload');

// Route untuk memulai percakapan baru.
router.post('/start', upload.single('file'), chatController.startNewChat);

// Route untuk melanjutkan percakapan yang sudah ada.
router.post('/:conversationId/message', upload.single('file'), chatController.continueChat);

module.exports = router;
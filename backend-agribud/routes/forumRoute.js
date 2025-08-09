// routes/forumRoute.js

const express = require('express');
const router = express.Router();
const forumController = require('../controllers/forumController');
// Nanti di sini bisa ditambahkan middleware untuk otentikasi
// const authMiddleware = require('../middleware/auth');

// --- Routes untuk Postingan ---
router.get('/posts', forumController.getAllPosts);
router.get('/posts/:postId', forumController.getPostById); 
router.post('/posts', forumController.createPost); 
router.post('/posts/:postId/like', forumController.toggleLike);

// --- Routes untuk Balasan (Replies) ---
router.post('/posts/:postId/reply', forumController.createReply);
router.post('/replies/:replyId/like', forumController.toggleLike);
router.patch('/replies/:replyId/approve', forumController.approveReply);

module.exports = router;
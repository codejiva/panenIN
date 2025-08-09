// routes/forumRoute.js

const express = require('express');
const router = express.Router();
const forumController = require('../controllers/forumController');

// Endpoint untuk mendapatkan semua postingan forum
router.get('/posts', forumController.getAllPosts);

// Endpoint untuk membuat postingan baru
router.post('/posts', forumController.createPost);

// Endpoint untuk memberi balasan pada sebuah postingan
router.post('/posts/:postId/reply', forumController.replyToPost);

module.exports = router;
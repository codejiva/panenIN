const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

// notifikasi untuk user tertentu (yang login aje)
router.get('/:userId', notificationController.getNotifications);

// tandain satu notifikasi sebagai sudah dibaca
router.patch('/:notificationId/read', notificationController.markAsRead);

// tandain semua notifikasi sbg udah dibaca
router.post('/read-all', notificationController.markAllAsRead);

module.exports = router;
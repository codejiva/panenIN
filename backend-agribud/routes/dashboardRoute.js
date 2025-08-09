const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

// Endpoint untuk mendapatkan ringkasan dashboard terakhir
router.get('/summary', dashboardController.getLatestSummary);

// Endpoint untuk memicu pembuatan ringkasan harian baru (untuk testing)
router.post('/generate-summary', dashboardController.generateDailySummary);

module.exports = router;

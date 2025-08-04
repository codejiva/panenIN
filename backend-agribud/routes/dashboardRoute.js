const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

router.get('/data', dashboardController.getDashboardData);
router.get('/', dashboardController.getDashboardData);

module.exports = router;

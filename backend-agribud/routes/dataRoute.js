const express = require('express');
const router = express.Router();
const dataController = require('../controllers/dataController');

// Endpoint: GET /api/data/provinces
router.get('/provinces', dataController.getProvinces);

module.exports = router;
const express = require('express');
const router = express.Router();
const { searchKabupaten } = require('../controllers/searchController');

router.get('/search', searchKabupaten);

module.exports = router;

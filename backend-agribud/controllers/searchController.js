const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');

router.get('/', searchController.searchKabupaten);

module.exports = router;

const shapefile = require('shapefile');
const { getShapefilePath } = require('../services/shapefileService');

exports.searchKabupaten = async (req, res) => {
  const { kabupaten } = req.query;

  if (!kabupaten) {
    return res.status(400).json({ message: 'Query parameter "kabupaten" is required.' });
  }

  try {
    const shpPath = getShapefilePath();
    // Library shapefile akan otomatis mencari file .dbf yang namanya sama
    const dbfPath = shpPath.replace('.shp', '.dbf');
    const data = [];

    const source = await shapefile.open(shpPath, dbfPath);
    let result;
    
    while (!(result = await source.read()).done) {
      const properties = result.value.properties;
      // Sesuaikan 'WADMKK' jika nama kolom di shapefile-mu berbeda
      if (properties && typeof properties.WADMKK === 'string' && properties.WADMKK.toLowerCase().includes(kabupaten.toLowerCase())) {
        data.push({
          nama_kabupaten: properties.WADMKK,
          provinsi: properties.WADMPR, // Sesuaikan juga 'WADMPR' jika perlu
          koordinat: result.value.geometry.coordinates
        });
      }
    }

    if (data.length === 0) {
      return res.status(404).json({ message: 'Kabupaten not found.' });
    }

    res.json(data);

  } catch (error) {
    console.error("Error searching kabupaten:", error);
    res.status(500).json({ message: 'Server error during map search.' });
  }
};

const { getGeoData } = require('../services/shapefileService');
const simplify = require('simplify-geojson');
const shapefile = require('shapefile');
const path = require('path');

exports.searchKabupaten = async (req, res) => {
  const { kabupaten } = req.query;

  if (!kabupaten) {
    return res.status(400).json({ message: 'Query parameter "kabupaten" harus diisi.' });
  }

  try {
    const filePath = path.join(__dirname, '../shapefiles/Batas_Kabupaten_BIG_PPBW_V1.shp');
    const dbfPath = filePath.replace('.shp', '.dbf');
    const data = [];

    const source = await shapefile.open(filePath, dbfPath);
    let result;
    
    while (!(result = await source.read()).done) {
      const properties = result.value.properties;

      // ini gue bikin buat ngecek sblm tolowercase
      if (properties.WADMKK && properties.WADMKK.toLowerCase().includes(kabupaten.toLowerCase())) {
        data.push({
          nama_kabupaten: properties.WADMKK,
          provinsi: properties.WADMPR,
          koordinat: result.value.geometry.coordinates
        });
      }
    }

    if (data.length === 0) {
      return res.status(404).json({ message: 'Kabupaten tidak ditemukan.' });
    }

    res.json(data);

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Terjadi kesalahan di server.' });
  }
};

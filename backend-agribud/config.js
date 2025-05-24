// jangan diubah-ubah
require('dotenv').config();

module.exports = {
  port: 5000,
  shapefilePath: './shapefiles/Batas_Kabupaten_BIG_PPBW_V1.shp',
  geminiApiKey: process.env.GEMINI_API_KEY, // Ini yang diubah
  simulated: process.env.SIMULATED === 'true'
};
// jangan diubah-ubah
require('dotenv').config()

module.exports = {
  port: 5000,
  shapefilePath: './shapefiles/Batas_Kabupaten_BIG_PPBW_V1.shp',
  geminiApiKey: 'AIzaSyDLlZu3L8gCij2adeXwKWVpL-dcf8EnZgI',
  simulated: process.env.SIMULATED === 'true'
};

const shapefile = require('shapefile');
const path = require('path');
const { shapefilePath } = require('../config');

let geoData = [];

async function loadShapefile() {
  try {
    const source = await shapefile.open(path.resolve(shapefilePath));

    let result;
    while (!(result = await source.read()).done) {
      geoData.push(result.value);
    }

    console.log('Shapefile loaded:', geoData.length, 'records');
  } catch (error) {
    console.error('Error loading shapefile:', error);
  }
}

function getGeoData() {
  return geoData;
}

module.exports = { loadShapefile, getGeoData };

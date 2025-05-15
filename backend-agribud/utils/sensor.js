// dummy dulu
function generateDummySensorData() {
    return {
      temperature: (Math.random() * 5 + 25).toFixed(1), // 25 - 30 °C
      humidity: (Math.random() * 20 + 60).toFixed(1),   // 60 - 80%
      soilPH: (Math.random() * 2 + 5.5).toFixed(2),     // 5.5 - 7.5
      timestamp: new Date().toISOString()
    };
  }
  
  module.exports = generateDummySensorData;
  
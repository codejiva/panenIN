const generateDummySensorData = require('../utils/sensor');

exports.getDashboardData = (req, res) => {
  const data = generateDummySensorData();
  res.status(200).json(data);
};

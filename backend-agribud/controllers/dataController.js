const provinces = require('../utils/provinces');

// ngirim daftar provinsi
exports.getProvinces = (req, res) => {
  try {
    res.status(200).json(provinces);
  } catch (error) {
    console.error("Error fetching provinces:", error);
    res.status(500).json({ message: 'Server error while fetching provinces.' });
  }
};
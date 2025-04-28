const userModel = require('../models/userModel');
const bcrypt = require('bcryptjs');

exports.register = async (req, res) => {
  const { username, email, password, region } = req.body;

  userModel.findUserByUsername(username, async (err, results) => {
    if (err) return res.status(500).json({ message: 'Server error', error: err });
    if (results.length > 0) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    userModel.createUser(username, email, hashedPassword, region, (err, result) => {
      if (err) return res.status(500).json({ message: 'Server error', error: err });
      res.status(201).json({ message: 'User registered successfully' });
    });
  });
};

exports.login = async (req, res) => {
  const { username, password } = req.body;

  userModel.findUserByUsername(username, async (err, results) => {
    if (err) return res.status(500).json({ message: 'Server error', error: err });
    if (results.length === 0) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const user = results[0];

    console.log('Password dari database (hashed):', user.password);
    console.log('Password yang dimasukkan oleh user:', password);

    const match = await bcrypt.compare(password, user.password);

    // ini gue bikin buat testing aja. bisa dihapus.  
    console.log('Cocok gak? ', match);

    if (!match) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    res.json({ message: 'Login successful' });
  });
};





// controllers/authController.js
const userModel = require('../models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

/**
 * Registrasi pengguna baru dengan pemilihan peran.
 */
exports.register = async (req, res) => {
  // Ambil 'role' dari body. Jika tidak ada, default ke 'farmer'.
  const { username, email, password, region, role = 'farmer' } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Username, email, and password are required.' });
  }

  try {
    const existingUser = await userModel.findUserByUsername(username);
    if (existingUser) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    
    // ---- PERUBAHAN DI SINI ----
    // Tentukan role_id berdasarkan input string 'role'.
    // Berdasarkan SQL kita, 1 = farmer, 2 = advisor.
    let roleId = 1; // Default ke farmer
    if (role.toLowerCase() === 'advisor') {
        roleId = 2;
    }
    // -------------------------

    // Kirim roleId ke fungsi createUser di model
    await userModel.createUser(username, email, hashedPassword, region, roleId);

    res.status(201).json({ message: 'User registered successfully' });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Server error during registration.' });
  }
};


/**
 * Login pengguna dan berikan JWT (Tidak ada perubahan di sini).
 */
exports.login = async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required.' });
  }

  try {
    const user = await userModel.findUserByUsername(username);
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const payload = {
      userId: user.id,
      username: user.username,
      role: user.role_name
    };

    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({
      message: 'Login successful',
      token: token,
      user: {
          id: user.id,
          username: user.username,
          role: user.role_name
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login.' });
  }
};
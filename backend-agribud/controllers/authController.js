const userModel = require('../models/userModel');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const provinces = require('../utils/provinces');

/**
 * Registrasi pengguna baru (Tidak ada perubahan di sini).
 */
exports.register = async (req, res) => {
  const { username, email, password, region, role = 'farmer' } = req.body;

  if (!username || !email || !password || !region) {
    return res.status(400).json({ message: 'Username, email, password, and region are required.' });
  }

  if (!provinces.includes(region)) {
    return res.status(400).json({ 
      message: `Invalid region. '${region}' is not a valid province.`,
      validProvinces: provinces 
    });
  }

  try {
    const existingUser = await userModel.findUserByUsername(username);
    if (existingUser) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    
    let roleId = 1;
    if (role.toLowerCase() === 'advisor') {
        roleId = 2;
    }

    await userModel.createUser(username, email, hashedPassword, region, roleId);

    res.status(201).json({ message: 'User registered successfully' });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Server error during registration.' });
  }
};


/**
 * Login pengguna menggunakan username ATAU email.
 */
exports.login = async (req, res) => {
  // --- PERUBAHAN DI SINI ---
  // Frontend akan mengirim 'identifier' yang bisa berisi username atau email.
  const { identifier, password } = req.body;

  if (!identifier || !password) {
    return res.status(400).json({ message: 'Identifier and password are required.' });
  }

  try {
    // Panggil fungsi model yang baru
    const user = await userModel.findUserByLoginIdentifier(identifier);
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const payload = {
      userId: user.id,
      username: user.username, // Selalu kembalikan username untuk konsistensi
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
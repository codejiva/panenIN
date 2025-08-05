// models/userModel.js
const db = require('../config/db');

/**
 * Membuat user baru di database.
 */
const createUser = async (username, email, hashedPassword, region, roleId) => {
  const sql = 'INSERT INTO users (username, email, password, region, role_id) VALUES (?, ?, ?, ?, ?)';
  const [result] = await db.query(sql, [username, email, hashedPassword, region, roleId]);
  return result;
};

/**
 * Mencari user berdasarkan username (digunakan untuk cek saat registrasi).
 */
const findUserByUsername = async (username) => {
  const sql = `
    SELECT u.*, r.name AS role_name 
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.username = ?
  `;
  const [rows] = await db.query(sql, [username]);
  return rows[0];
};

/**
 * FUNGSI BARU: Mencari user berdasarkan username ATAU email untuk login.
 */
const findUserByLoginIdentifier = async (identifier) => {
  // Cek sederhana apakah identifier terlihat seperti email
  const isEmail = identifier.includes('@');
  
  // Tentukan kolom mana yang akan dicari berdasarkan tipe identifier
  const columnToSearch = isEmail ? 'u.email' : 'u.username';

  const sql = `
    SELECT u.*, r.name AS role_name 
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE ${columnToSearch} = ?
  `;
  const [rows] = await db.query(sql, [identifier]);
  return rows[0]; // Kembalikan user object atau undefined
};


module.exports = {
  createUser,
  findUserByUsername,
  findUserByLoginIdentifier // Export fungsi baru
};
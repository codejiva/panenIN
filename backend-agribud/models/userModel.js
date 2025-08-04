// models/userModel.js
const db = require('../config/db');

/**
 * Membuat user baru di database.
 */
const createUser = async (username, email, hashedPassword, region, roleId) => { // <-- pastikan ada 'roleId'
  const sql = 'INSERT INTO users (username, email, password, region, role_id) VALUES (?, ?, ?, ?, ?)';
  const [result] = await db.query(sql, [username, email, hashedPassword, region, roleId]); // <-- 'roleId' digunakan di sini
  return result;
};

/**
 * Mencari user berdasarkan username.
 * Menggabungkan (JOIN) dengan tabel roles untuk mendapatkan nama peran.
 */
const findUserByUsername = async (username) => {
  const sql = `
    SELECT u.*, r.name AS role_name 
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.username = ?
  `;
  const [rows] = await db.query(sql, [username]);
  return rows[0]; // Kembalikan user object atau undefined jika tidak ditemukan
};

module.exports = {
  createUser,
  findUserByUsername
};
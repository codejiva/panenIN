// config/db.js
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'agribuddy',
  port: process.env.DB_PORT || 3306,
  ssl: {
    rejectUnauthorized: true // ! buat di cloud aja ini.
  },
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

console.log('Koneksi pool untuk database MySQL/TiDB dibuat.');
module.exports = pool;
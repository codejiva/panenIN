const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

// TiDB Cloud butuh sertifikat CA khusus buat koneksi SSL
// buat vercel
const caPath = path.resolve(__dirname, 'isrgrootx1.pem');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 4000, // gue samain dengan port TiDB Cloud 4000
  ssl: {
    // serti CA
    ca: fs.readFileSync(caPath),
    // biar aman
    minVersion: 'TLSv1.2',
    rejectUnauthorized: true
  },
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

console.log('Koneksi pool untuk database TiDB Cloud dikonfigurasi.');
module.exports = pool;

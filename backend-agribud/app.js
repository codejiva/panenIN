// Memuat environment variables dari file .env
require('dotenv').config();

// --- Import Semua Library yang Dibutuhkan ---
const express = require('express');
const cors = require('cors');
const http = require('http');
const chalk = require('chalk');

// --- Import Routes & Services ---
const searchRoute = require('./routes/searchRoute');
const authRoutes = require('./routes/authRoute');
const chatRoute = require('./routes/chatRoute');
const dashboardRoutes = require('./routes/dashboardRoute');
const forumRoute = require('./routes/forumRoute');
const notificationRoute = require('./routes/notificationRoute');
const { loadShapefile } = require('./services/shapefileService'); // <-- Dideklarasikan HANYA SEKALI di sini

// --- Inisialisasi Server ---
const app = express();
const server = http.createServer(app);

// --- Middleware ---
app.use(cors());
app.use(express.json());

// --- Konfigurasi Routes ---
app.use('/api/search', searchRoute);
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoute);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/forum', forumRoute);
app.use('/api/notifications', notificationRoute);


// --- Tampilkan Banner dan Muat Data Penting ---
loadShapefile().then(() => {
  console.log(chalk.green.bold(`
    █████╗  ██████╗██████╗ ██╗██████╗ ██╗   ██╗██████╗ 
   ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗██║   ██║██╔══██╗
   ███████║██║  ██║██████╔╝██║██████╔╝██║   ██║██║  ██║
   ██╔══██║██║  ██║██╔══██╗██║██╔══██╗██║   ██║██║  ██║
   ██║  ██║╚██████║██║  ██║██║██████╔╝╚██████╔╝██████╔╝
   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚═════╝ 
  `));
  console.log(chalk.blue.bold('Shapefile berhasil dimuat. Server siap menerima request.'));
}).catch(err => {
    console.error(chalk.red.bold("Gagal memuat shapefile, beberapa API mungkin tidak berfungsi."), err);
});


// --- Logika Socket.IO & Menjalankan Server (HANYA JALAN DI LOKAL) ---
if (process.env.NODE_ENV !== 'production') {
  const { Server } = require('socket.io');
  const io = new Server(server, { cors: { origin: "*", methods: ["GET", "POST"] }});
  io.on('connection', (socket) => { 
      // Logika socket.io untuk data dummy
      const interval = setInterval(() => {
        socket.emit('sensorData', {
          suhu: (Math.random() * 10 + 25).toFixed(2),
          kelembapan: (Math.random() * 20 + 60).toFixed(2),
          ph_tanah: (Math.random() * 3 + 5.5).toFixed(2),
          cahaya: (Math.random() * 5000 + 10000).toFixed(0)
        });
      }, 3000);
      socket.on('disconnect', () => {
        clearInterval(interval);
      });
  });
  
  const PORT = process.env.PORT || 5000;
  server.listen(PORT, () => console.log(
    chalk.green.bold(`--- SERVER LOKAL AKTIF di port ${PORT} ---`)
  ));
}

// --- Export aplikasi untuk Vercel ---
module.exports = app;

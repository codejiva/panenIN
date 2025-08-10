// Memuat environment variables dari file .env
require('dotenv').config();

// --- Import Semua Library yang Dibutuhkan ---
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const chalk = require('chalk');

// --- Import Routes ---
const searchRoute = require('./routes/searchRoute');
const authRoutes = require('./routes/authRoute');
const chatRoute = require('./routes/chatRoute');
const dashboardRoutes = require('./routes/dashboardRoute');
const forumRoute = require('./routes/forumRoute');
const notificationRoute = require('./routes/notificationRoute');


// --- Import Services ---
const { loadShapefile } = require('./services/shapefileService');

// --- Inisialisasi Server ---
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Mengizinkan koneksi dari mana saja
    methods: ["GET", "POST"]
  }
});

// --- Middleware ---
app.use(cors());
app.use(express.json()); // Middleware untuk mem-parsing body JSON

// --- Konfigurasi Routes ---
app.use('/api/search', searchRoute);
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoute);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/forum', forumRoute);
app.use('/api/notifications', notificationRoute);

// --- Logika Socket.IO untuk Dashboard Real-time ---
io.on('connection', (socket) => {
  // Tampilan waktu ada koneksi baru
  console.log(
    chalk.green.bold('🟢 Klien terkoneksi:'),
    chalk.cyan.bold(socket.id),
    chalk.gray(`(Total: ${io.engine.clientsCount})`)
  );

  // Simulasi pengiriman data sensor setiap 3 detik
  const interval = setInterval(() => {
    const sensorData = {
      suhu: (Math.random() * 10 + 25).toFixed(2),       // 25 - 35 °C
      kelembapan: (Math.random() * 20 + 60).toFixed(2), // 60 - 80%
      ph_tanah: (Math.random() * 3 + 5.5).toFixed(2),   // 5.5 - 8.5
      cahaya: (Math.random() * 5000 + 10000).toFixed(0) // 10,000 - 15,000 lux
    };
    socket.emit('sensorData', sensorData);
  }, 3000);

  socket.on('disconnect', () => {
    clearInterval(interval);
    // Tampilan waktu client disconnect
    console.log(
      chalk.red.bold('🔴 Klien terputus:'),
      chalk.cyan.bold(socket.id),
      chalk.gray(`(Sisa: ${io.engine.clientsCount})`)
    );
  });
});

// --- Menjalankan Server ---
// Menggunakan port dari environment variable (untuk Render) atau 5000 (untuk lokal)
const PORT = process.env.PORT || 5000;

// Memuat shapefile terlebih dahulu, baru jalankan server
loadShapefile().then(() => {
  // Banner keren waktu server start
  console.log(chalk.green.bold(`
    █████╗  ██████╗██████╗ ██╗██████╗ ██╗   ██╗██████╗ 
   ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗██║   ██║██╔══██╗
   ███████║██║  ██║██████╔╝██║██████╔╝██║   ██║██║  ██║
   ██╔══██║██║  ██║██╔══██╗██║██╔══██╗██║   ██║██║  ██║
   ██║  ██║╚██████║██║  ██║██║██████╔╝╚██████╔╝██████╔╝
   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚═════╝ 
  `));
  
  server.listen(PORT, () => console.log(
    chalk.green.bold(`Server jalan di port ${PORT}, warga!`),
    chalk.gray('\nTekan CTRL+C untuk berhenti di lokal.')
  ));
}).catch(err => {
    console.error(chalk.red.bold("Gagal memuat shapefile, server tidak dapat dimulai."), err);
    process.exit(1); // Keluar dari proses jika shapefile gagal dimuat
});

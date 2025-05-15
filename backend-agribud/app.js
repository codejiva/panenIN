const express = require('express');
const cors = require('cors');
const searchRoute = require('./routes/searchRoute');
const authRoutes = require('./routes/authRoute');
const chatRoute = require('./routes/chatRoute');
const dashboardRoutes = require('./routes/dashboardRoute');
const { port } = require('./config');
const { loadShapefile } = require('./services/shapefileService');
const http = require('http');
const { Server } = require('socket.io');
const chalk = require('chalk');

const app = express();
const server = http.Server(app); // ganti app.listen jadi server.listen kalo mau dijalanin. nggak tau gue juga kenapa ini aaowkoakwoakwokawk
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// middleware sama route gue taro sini. jangan ada yang diubah yak
app.use(cors());
app.use(express.json());

app.use('/api', searchRoute);
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoute);
app.use('/api/dashboard', dashboardRoutes);

// ini buat simulasi datanya
io.on('connection', (socket) => {
  // Tampilan waktu ada koneksi baru
  console.log(
    chalk.green.bold('🟢 Klien terkoneksi:'),
    chalk.cyan.bold(socket.id),
    chalk.gray(`(Total: ${io.engine.clientsCount})`)
  );

  // simulasi aja yak
  const interval = setInterval(() => {
    const sensorData = {
      suhu: (Math.random() * 10 + 25).toFixed(2),      // 25 - 35 °C
      kelembapan: (Math.random() * 20 + 60).toFixed(2), // 60 - 80%
      ph_tanah: (Math.random() * 3 + 5.5).toFixed(2),  // 5.5 - 8.5 (kira-kira seginian pH tanah normal)
      cahaya: (Math.random() * 5000 + 10000).toFixed(0) // 10,000 - 15,000 lux (intensitas cahaya umumnya segini kecuali mendekati kiamat)
    };
    socket.emit('sensorData', sensorData);
    
    // data yang dikirim ke client
    console.log(
      chalk.yellow.bold('📊 Data Sensor:'),
      `🌡️ ${chalk.red.bold(sensorData.suhu + '°C')}`,
      `💧 ${chalk.blue.bold(sensorData.kelembapan + '%')}`,
      `🧪 ${chalk.magenta.bold('pH:' + sensorData.ph_tanah)}`,
      `☀️ ${chalk.yellow.bold(sensorData.cahaya + ' lux')}`,
      chalk.gray(`-> ${socket.id}`)
    );
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

// ini buat load shp. kalo udah, jalanin servernya
loadShapefile().then(() => {
  // Banner keren waktu server start biar keren anjay gurinjay
  console.log(chalk.green.bold(`
    █████╗  ██████╗██████╗ ██╗██████╗ ██╗   ██╗██████╗ 
   ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗██║   ██║██╔══██╗
   ███████║██║  ██║██████╔╝██║██████╔╝██║   ██║██║  ██║
   ██╔══██║██║  ██║██╔══██╗██║██╔══██╗██║   ██║██║  ██║
   ██║  ██║╚██████║██║  ██║██║██████╔╝╚██████╔╝██████╔╝
   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚═════╝ 
 `));
  server.listen(port, () => console.log(
    chalk.green.bold(`Server jalan di port ${port} ya, warga!`),
    chalk.gray('\nTekan CTRL+C untuk berhenti'),
    chalk.gray('\nHubungi tim IT jika terdapat kendala.')
  ));
});
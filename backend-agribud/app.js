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
  console.log('Klien terkoneksi:', socket.id);

  // simulasi aja yak
  const interval = setInterval(() => {
    const sensorData = {
      suhu: (Math.random() * 10 + 25).toFixed(2),      // 25 - 35 °C
      kelembapan: (Math.random() * 20 + 60).toFixed(2) // 60 - 80%
    };
    socket.emit('sensorData', sensorData);
  }, 3000);

  socket.on('disconnect', () => {
    clearInterval(interval);
    console.log('Klien terputus:', socket.id);
  });
});

// ini buat load shp. kalo udah, jalanin servernya
loadShapefile().then(() => {
  server.listen(port, () => console.log(`Server jalan di port ${port} ya, warga!`));
});

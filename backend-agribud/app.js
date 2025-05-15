const express = require('express');
const cors = require('cors');
const searchRoute = require('./routes/searchRoute');
const authRoutes = require('./routes/authRoute');
const chatRoute = require('./routes/chatRoute');
const dashboardRoutes = require('./routes/dashboardRoutes');
const { port } = require('./config');
const { loadShapefile } = require('./services/shapefileService');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api', searchRoute);
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoute);
app.use('/api/dashboard', dashboardRoutes);

loadShapefile().then(() => {
  app.listen(port, () => console.log(`Server jalan di port ${port} ya, warga!`));
});

const express = require('express');
const cors = require('cors');
const { port } = require('./config');
const searchRoute = require('./routes/searchRoute');
const { loadShapefile } = require('./services/shapefileService');
const authRoutes = require('./routes/authRoute');
const chatRoute = require('./routes/chatRoute');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api', searchRoute);
app.use('/api/auth', authRoutes);
app.use('/api/chat', chatRoute);

loadShapefile().then(() => {
  app.listen(port, () => console.log(`Server jalan di port ${port} ya, warga!`));
});

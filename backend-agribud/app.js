const express = require('express');
const cors = require('cors');
const { port } = require('./config');
const searchRoute = require('./routes/searchRoute');
const { loadShapefile } = require('./services/shapefileService');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api', searchRoute);

loadShapefile().then(() => {
  app.listen(port, () => console.log(`Server running on port ${port}`));
});

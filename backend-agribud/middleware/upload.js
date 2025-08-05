// middleware/upload.js
const multer = require('multer');

// Simpan file di memori sementara, bukan di disk server
const storage = multer.memoryStorage();

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 15 * 1024 * 1024, // ! DIBATESIN 15 MB
  },
});

module.exports = upload;
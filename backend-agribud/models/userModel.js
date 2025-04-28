const db = require('../config/db');
const bcrypt = require('bcryptjs');

exports.createUser = (username, email, password, region, callback) => {
  db.query(
    'INSERT INTO users (username, email, password, region) VALUES (?, ?, ?, ?)',
    [username, email, password, region],
    (err, result) => {
      if (err) {
        return callback(err, null);
      }
      callback(null, result);
    }
  );
};

exports.findUserByUsername = (username, callback) => {
  db.query(
    'SELECT * FROM users WHERE username = ?',
    [username],
    callback
  );
};


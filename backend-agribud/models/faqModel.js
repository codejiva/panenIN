// models/faqModel.js
const db = require('../config/db');

/**
 * Mengambil semua data FAQ dari database, TERMASUK KEYWORDS.
 */
const getAllFaqs = async () => {
  // PERUBAHAN DI SINI: Menambahkan kolom 'keywords' ke dalam query SELECT
  const sql = 'SELECT id, question, answer, keywords FROM faq';
  const [rows] = await db.query(sql);
  return rows;
};

module.exports = {
  getAllFaqs
};
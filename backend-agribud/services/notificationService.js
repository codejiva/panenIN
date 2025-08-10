const pool = require('../config/db');

/**
 * kurleb kyk gini
 * @param {number} recipientId - ID user penerima notifikasi.
 * @param {number|null} senderId - ID user pengirim (null untuk sistem).
 * @param {string} type - Tipe notifikasi ('LIKE_POST', 'NEW_REPLY', dll).
 * @param {object} target - Objek berisi info target (misal: { id: 1, title: 'Judul Post' }).
 * @param {string} senderUsername - Username pengirim.
 */
const createNotification = async (recipientId, senderId, type, target, senderUsername) => {
  // Jangan kirim notifikasi ke diri sendiri y
  if (recipientId === senderId) return;

  let message = '';
  let target_url = '';

  switch (type) {
    case 'LIKE_POST':
      message = `${senderUsername} menyukai postingan Anda: "${target.title.substring(0, 30)}..."`;
      target_url = `/posts/${target.id}`;
      break;
    case 'LIKE_REPLY':
      message = `${senderUsername} menyukai balasan Anda: "${target.content.substring(0, 30)}..."`;
      target_url = `/posts/${target.postId}`;
      break;
    case 'NEW_REPLY':
      message = `${senderUsername} membalas postingan Anda: "${target.title.substring(0, 30)}..."`;
      target_url = `/posts/${target.id}`;
      break;
    case 'REPLY_APPROVED':
      message = `Seorang Advisor telah menyetujui balasan Anda di postingan: "${target.title.substring(0, 30)}..."`;
      target_url = `/posts/${target.postId}`;
      break;
    case 'DAILY_SUMMARY':
      message = `Ringkasan agrikultur harian untuk tanggal ${new Date().toLocaleDateString('id-ID')} sudah tersedia!`;
      target_url = `/dashboard`;
      break;
    // kalo gue kebayang sesuatu nanti gue tambahin
  }

  if (message) {
    const sql = 'INSERT INTO notifications (recipient_id, sender_id, type, message, target_url) VALUES (?, ?, ?, ?, ?)';
    await pool.query(sql, [recipientId, senderId, type, message, target_url]);
  }
};

module.exports = { createNotification };
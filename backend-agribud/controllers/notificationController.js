const pool = require('../config/db');

// dapetin notifikasi
exports.getNotifications = async (req, res) => {
  const { userId } = req.params;
  try {
    const sql = 'SELECT * FROM notifications WHERE recipient_id = ? ORDER BY created_at DESC';
    const [notifications] = await pool.query(sql, [userId]);
    res.status(200).json(notifications);
  } catch (error) {
    console.error("Error fetching notifications:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// tandain satu npotif udah dbaca
exports.markAsRead = async (req, res) => {
  const { notificationId } = req.params;
  try {
    const sql = 'UPDATE notifications SET is_read = TRUE WHERE id = ?';
    await pool.query(sql, [notificationId]);
    res.status(200).json({ message: 'Notification marked as read.' });
  } catch (error) {
    console.error("Error marking notification as read:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// semua notif dianggap udah dibaca
exports.markAllAsRead = async (req, res) => {
    const { userId } = req.body;
    if (!userId) {
        return res.status(400).json({ message: 'userId is required.' });
    }
  try {
    const sql = 'UPDATE notifications SET is_read = TRUE WHERE recipient_id = ?';
    await pool.query(sql, [userId]);
    res.status(200).json({ message: 'All notifications marked as read.' });
  } catch (error) {
    console.error("Error marking all notifications as read:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

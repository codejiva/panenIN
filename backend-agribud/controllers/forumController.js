// controllers/forumController.js

const pool = require('../config/db');

// Mendapatkan semua postingan beserta balasannya dan info user
exports.getAllPosts = async (req, res) => {
  try {
    const postsQuery = `
      SELECT 
        p.id, p.title, p.content, p.created_at,
        u.username, r.name AS role_name
      FROM posts p
      JOIN users u ON p.user_id = u.id
      JOIN roles r ON u.role_id = r.id
      ORDER BY p.created_at DESC;
    `;
    const [posts] = await pool.query(postsQuery);

    // Untuk setiap post, ambil juga semua balasannya
    for (const post of posts) {
      const repliesQuery = `
        SELECT 
          rep.id, rep.content, rep.created_at,
          u.username, r.name AS role_name
        FROM replies rep
        JOIN users u ON rep.user_id = u.id
        JOIN roles r ON u.role_id = r.id
        WHERE rep.post_id = ?
        ORDER BY rep.created_at ASC;
      `;
      const [replies] = await pool.query(repliesQuery, [post.id]);
      post.replies = replies;
    }

    res.status(200).json(posts);
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({ message: 'Server error while fetching forum posts.' });
  }
};

// Membuat postingan baru
exports.createPost = async (req, res) => {
  const { userId, title, content } = req.body;
  if (!userId || !title || !content) {
    return res.status(400).json({ message: 'userId, title, and content are required.' });
  }

  try {
    const sql = 'INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)';
    await pool.query(sql, [userId, title, content]);
    res.status(201).json({ message: 'Post created successfully.' });
  } catch (error)
 {
    console.error("Error creating post:", error);
    res.status(500).json({ message: 'Server error while creating post.' });
  }
};

// Memberi balasan pada sebuah postingan
exports.replyToPost = async (req, res) => {
  const { postId } = req.params;
  const { userId, content } = req.body;

  if (!userId || !content) {
    return res.status(400).json({ message: 'userId and content are required.' });
  }

  try {
    const sql = 'INSERT INTO replies (post_id, user_id, content) VALUES (?, ?, ?)';
    await pool.query(sql, [postId, userId, content]);
    res.status(201).json({ message: 'Reply added successfully.' });
  } catch (error) {
    console.error("Error replying to post:", error);
    res.status(500).json({ message: 'Server error while replying.' });
  }
};

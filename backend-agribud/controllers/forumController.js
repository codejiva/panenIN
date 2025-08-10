// controllers/forumController.js

const pool = require('../config/db');

// --- Helper Function untuk membangun struktur nested replies ---
const buildReplyTree = (replies, parentId = null) => {
  const tree = [];
  replies.forEach(reply => {
    if (reply.parent_reply_id === parentId) {
      const children = buildReplyTree(replies, reply.id);
      if (children.length) {
        reply.children = children;
      }
      tree.push(reply);
    }
  });
  return tree;
};

// --- Controller Functions ---

// Dapatkan semua postingan dengan sorting DAN PENCARIAN (judul atau ID)
exports.getAllPosts = async (req, res) => {
  const sortBy = req.query.sortBy || 'created_at';
  const order = req.query.order || 'DESC';
  const search = req.query.search || '';

  if (!['created_at', 'reply_count'].includes(sortBy) || !['ASC', 'DESC'].includes(order.toUpperCase())) {
    return res.status(400).json({ message: 'Invalid sort parameters.' });
  }

  try {
    let postsQuery = `
      SELECT 
        p.id, p.title, p.content, p.created_at,
        u.username, r.name AS role_name,
        (SELECT COUNT(*) FROM replies WHERE post_id = p.id) AS reply_count
      FROM posts p
      JOIN users u ON p.user_id = u.id
      JOIN roles r ON u.role_id = r.id
    `;
    const queryParams = [];

    if (search) {
      const searchId = parseInt(search, 10);
      if (!isNaN(searchId) && searchId.toString() === search) {
        postsQuery += ` WHERE p.id = ?`;
        queryParams.push(searchId);
      } else {
        postsQuery += ` WHERE p.title LIKE ?`;
        queryParams.push(`%${search}%`);
      }
    }

    postsQuery += ` ORDER BY ${sortBy === 'reply_count' ? 'reply_count' : 'p.created_at'} ${order.toUpperCase()};`;
    
    const [posts] = await pool.query(postsQuery, queryParams);
    res.status(200).json(posts);
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Dapatkan satu post dengan nested replies
exports.getPostById = async (req, res) => {
  const { postId } = req.params;
  const sortBy = req.query.sortBy || 'created_at';
  const order = req.query.order || 'ASC';
  const filter = req.query.filter;

  try {
    const postQuery = `
      SELECT p.id, p.title, p.content, p.created_at, p.user_id AS author_id, u.username, r.name AS role_name
      FROM posts p
      JOIN users u ON p.user_id = u.id
      JOIN roles r ON u.role_id = r.id
      WHERE p.id = ?;
    `;
    const [posts] = await pool.query(postQuery, [postId]);
    if (posts.length === 0) {
      return res.status(404).json({ message: 'Post not found.' });
    }
    const post = posts[0];

    let repliesQuery = `
      SELECT 
        rep.id, rep.content, rep.created_at, rep.parent_reply_id, rep.is_expert_approved,
        u.id AS user_id, u.username, r.name AS role_name,
        (SELECT COUNT(*) FROM likes WHERE reply_id = rep.id) AS like_count,
        (CASE WHEN rep.user_id = ? THEN 1 ELSE 0 END) AS is_op
      FROM replies rep
      JOIN users u ON rep.user_id = u.id
      JOIN roles r ON u.role_id = r.id
      WHERE rep.post_id = ?
    `;

    if (filter === 'approved') {
      repliesQuery += ' AND rep.is_expert_approved = 1';
    }

    const orderByClause = sortBy === 'like_count' ? 'like_count' : 'rep.created_at';
    repliesQuery += ` ORDER BY ${orderByClause} ${order.toUpperCase()};`;

    const [replies] = await pool.query(repliesQuery, [post.author_id, postId]);

    post.replies = buildReplyTree(replies);

    res.status(200).json(post);
  } catch (error) {
    console.error("Error fetching post by ID:", error);
    res.status(500).json({ message: 'Server error.' });
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
  } catch (error) {
    console.error("Error creating post:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Membuat balasan baru
exports.createReply = async (req, res) => {
  const { postId } = req.params;
  const { userId, content, parentReplyId = null } = req.body;

  if (!userId || !content) {
    return res.status(400).json({ message: 'userId and content are required.' });
  }
  try {
    const sql = 'INSERT INTO replies (post_id, user_id, content, parent_reply_id) VALUES (?, ?, ?, ?)';
    await pool.query(sql, [postId, userId, content, parentReplyId]);
    res.status(201).json({ message: 'Reply added successfully.' });
  } catch (error) {
    console.error("Error creating reply:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// --- PERBAIKAN BUG DI SINI ---
// Like atau Unlike sebuah post atau reply
exports.toggleLike = async (req, res) => {
  const { postId, replyId } = req.params;
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({ message: 'userId is required.' });
  }

  // Tentukan target like (post atau reply)
  const isPostLike = !!postId;
  const targetId = postId || replyId;
  const targetColumn = isPostLike ? 'post_id' : 'reply_id';
  const otherColumn = isPostLike ? 'reply_id' : 'post_id';

  try {
    // Cek apakah user sudah pernah like item ini
    const checkSql = `SELECT id FROM likes WHERE user_id = ? AND ${targetColumn} = ?`;
    const [existingLikes] = await pool.query(checkSql, [userId, targetId]);

    if (existingLikes.length > 0) {
      // Jika sudah ada, hapus (unlike)
      const deleteSql = 'DELETE FROM likes WHERE id = ?';
      await pool.query(deleteSql, [existingLikes[0].id]);
      res.status(200).json({ message: 'Unliked successfully.' });
    } else {
      // Jika belum ada, tambahkan (like)
      const insertSql = `INSERT INTO likes (user_id, ${targetColumn}) VALUES (?, ?)`;
      await pool.query(insertSql, [userId, targetId]);
      res.status(201).json({ message: 'Liked successfully.' });
    }
  } catch (error) {
    console.error("Error toggling like:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Approve sebuah reply
exports.approveReply = async (req, res) => {
  const { replyId } = req.params;

  try {
    const sql = 'UPDATE replies SET is_expert_approved = TRUE WHERE id = ?';
    const [result] = await pool.query(sql, [replyId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Reply not found.' });
    }
    res.status(200).json({ message: 'Reply approved successfully.' });
  } catch (error) {
    console.error("Error approving reply:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

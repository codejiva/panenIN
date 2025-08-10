// controllers/forumController.js
const pool = require('../config/db');
const { createNotification } = require('../services/notificationService'); // <-- IMPORT

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

// Dapatkan semua postingan dengan sorting, pencarian, dan status 'is_liked'
exports.getAllPosts = async (req, res) => {
  const { sortBy = 'created_at', order = 'DESC', search = '', userId = null } = req.query;

  if (!['created_at', 'reply_count', 'like_count'].includes(sortBy) || !['ASC', 'DESC'].includes(order.toUpperCase())) {
    return res.status(400).json({ message: 'Invalid sort parameters.' });
  }

  try {
    let postsQuery = `
      SELECT 
        p.id, p.title, p.content, p.created_at,
        u.username, r.name AS role_name,
        (SELECT COUNT(*) FROM replies WHERE post_id = p.id) AS reply_count,
        (SELECT COUNT(*) FROM likes WHERE post_id = p.id) AS like_count,
        (CASE WHEN EXISTS (SELECT 1 FROM likes WHERE post_id = p.id AND user_id = ?) THEN 1 ELSE 0 END) AS is_liked
      FROM posts p
      JOIN users u ON p.user_id = u.id
      JOIN roles r ON u.role_id = r.id
    `;
    const queryParams = [userId];

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

    const orderByClause = {
        'created_at': 'p.created_at',
        'reply_count': 'reply_count',
        'like_count': 'like_count'
    }[sortBy];

    postsQuery += ` ORDER BY ${orderByClause} ${order.toUpperCase()};`;
    
    const [posts] = await pool.query(postsQuery, queryParams);
    res.status(200).json(posts);
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};


// Dapatkan satu post dengan nested replies dan status 'is_liked'
exports.getPostById = async (req, res) => {
  const { postId } = req.params;
  const { sortBy = 'created_at', order = 'ASC', filter = null, userId = null } = req.query;

  try {
    const postQuery = `
      SELECT 
        p.id, p.title, p.content, p.created_at, p.user_id AS author_id, 
        u.username, r.name AS role_name,
        (SELECT COUNT(*) FROM likes WHERE post_id = p.id) AS like_count,
        (CASE WHEN EXISTS (SELECT 1 FROM likes WHERE post_id = p.id AND user_id = ?) THEN 1 ELSE 0 END) AS is_liked
      FROM posts p
      JOIN users u ON p.user_id = u.id
      JOIN roles r ON u.role_id = r.id
      WHERE p.id = ?;
    `;
    const [posts] = await pool.query(postQuery, [userId, postId]);
    if (posts.length === 0) {
      return res.status(404).json({ message: 'Post not found.' });
    }
    const post = posts[0];

    let repliesQuery = `
      SELECT 
        rep.id, rep.content, rep.created_at, rep.parent_reply_id, rep.is_expert_approved,
        u.id AS user_id, u.username, r.name AS role_name,
        (SELECT COUNT(*) FROM likes WHERE reply_id = rep.id) AS like_count,
        (CASE WHEN EXISTS (SELECT 1 FROM likes WHERE reply_id = rep.id AND user_id = ?) THEN 1 ELSE 0 END) AS is_liked,
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

    const [replies] = await pool.query(repliesQuery, [userId, post.author_id, postId]);

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

    // --- BUAT NOTIFIKASI ---
    const [sender] = await pool.query('SELECT username FROM users WHERE id = ?', [userId]);
    
    // Notifikasi untuk pemilik post
    const [posts] = await pool.query('SELECT user_id, title FROM posts WHERE id = ?', [postId]);
    if (posts.length > 0) {
        await createNotification(posts[0].user_id, userId, 'NEW_REPLY', { id: postId, title: posts[0].title }, sender[0].username);
    }
    
    // Notifikasi untuk pemilik parent reply (jika ada)
    if (parentReplyId) {
        const [parentReplies] = await pool.query('SELECT user_id FROM replies WHERE id = ?', [parentReplyId]);
        if (parentReplies.length > 0) {
            await createNotification(parentReplies[0].user_id, userId, 'NEW_REPLY', { id: postId, title: posts[0].title }, sender[0].username);
        }
    }

    res.status(201).json({ message: 'Reply added successfully.' });
  } catch (error) {
    console.error("Error creating reply:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Like atau Unlike sebuah post atau reply
exports.toggleLike = async (req, res) => {
  const { postId, replyId } = req.params;
  const { userId } = req.body;

  if (!userId) return res.status(400).json({ message: 'userId is required.' });

  const isPostLike = !!postId;
  const targetId = postId || replyId;
  const targetColumn = isPostLike ? 'post_id' : 'reply_id';

  try {
    const checkSql = `SELECT id FROM likes WHERE user_id = ? AND ${targetColumn} = ?`;
    const [existingLikes] = await pool.query(checkSql, [userId, targetId]);

    if (existingLikes.length > 0) {
      const deleteSql = 'DELETE FROM likes WHERE id = ?';
      await pool.query(deleteSql, [existingLikes[0].id]);
      res.status(200).json({ message: 'Unliked successfully.' });
    } else {
      const insertSql = `INSERT INTO likes (user_id, ${targetColumn}) VALUES (?, ?)`;
      await pool.query(insertSql, [userId, targetId]);

      // --- BUAT NOTIFIKASI ---
      const [sender] = await pool.query('SELECT username FROM users WHERE id = ?', [userId]);
      if (isPostLike) {
          const [posts] = await pool.query('SELECT user_id, title FROM posts WHERE id = ?', [targetId]);
          if (posts.length > 0) {
            await createNotification(posts[0].user_id, userId, 'LIKE_POST', { id: targetId, title: posts[0].title }, sender[0].username);
          }
      } else {
          const [replies] = await pool.query('SELECT user_id, content, post_id FROM replies WHERE id = ?', [targetId]);
          if (replies.length > 0) {
            await createNotification(replies[0].user_id, userId, 'LIKE_REPLY', { postId: replies[0].post_id, content: replies[0].content }, sender[0].username);
          }
      }

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
  const { approverId } = req.body; // Kita butuh ID si advisor

  if (!approverId) {
      return res.status(400).json({ message: 'approverId is required.' });
  }

  try {
    const sql = 'UPDATE replies SET is_expert_approved = TRUE WHERE id = ?';
    const [result] = await pool.query(sql, [replyId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Reply not found.' });
    }

    // --- BUAT NOTIFIKASI ---
    const [replies] = await pool.query('SELECT r.user_id, p.title, p.id as postId FROM replies r JOIN posts p ON r.post_id = p.id WHERE r.id = ?', [replyId]);
    if (replies.length > 0) {
        await createNotification(replies[0].user_id, approverId, 'REPLY_APPROVED', { postId: replies[0].postId, title: replies[0].title }, 'Seorang Advisor');
    }

    res.status(200).json({ message: 'Reply approved successfully.' });
  } catch (error) {
    console.error("Error approving reply:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};



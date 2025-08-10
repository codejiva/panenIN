import 'dart:async';
import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/forum/models/forum_model.dart';
import 'package:PanenIn/features/forum/services/forum_service.dart';
import 'package:PanenIn/features/auth/services/auth_service.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ForumDetailScreen extends StatefulWidget {
  final String postId;

  const ForumDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ForumPost? forumPost;
  List<Reply> replies = [];
  bool isLoading = true;
  bool isSubmittingReply = false;
  String? errorMessage;
  Reply? replyingTo;

  // Track which posts/replies are being liked
  Set<int> likingPosts = {};

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Get user ID for like status - PENTING!
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      int? userId;

      if (authProvider.isLoggedIn && authProvider.userData != null) {
        userId = authProvider.userData?['id'] ??
            authProvider.userData?['user_id'] ??
            authProvider.userData?['userId'];
      }

      debugPrint('Loading post with userId: $userId');

      final post = await _forumService.getForumPost(
        int.parse(widget.postId),
        userId: userId, // KIRIM userId ke API!
      );

      if (mounted) {
        setState(() {
          forumPost = post;
          replies = post.replies ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load post details: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _submitReply() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      _showErrorSnackBar('You must be logged in to reply');
      return;
    }

    final content = _replyController.text.trim();
    if (content.isEmpty) {
      _showErrorSnackBar('Please enter your reply');
      return;
    }

    setState(() {
      isSubmittingReply = true;
    });

    try {
      final userId = authProvider.userData?['id'] ??
          authProvider.userData?['user_id'] ??
          authProvider.userData?['userId'];

      await _forumService.createReply(
        postId: int.parse(widget.postId),
        content: content,
        userId: userId,
        parentReplyId: replyingTo?.id,
      );

      _replyController.clear();
      setState(() {
        replyingTo = null;
      });

      _showSuccessSnackBar('Reply posted successfully!');

      // Add delay then refresh
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadPostDetails();

    } catch (e) {
      _showErrorSnackBar('Failed to post reply: $e');
    } finally {
      setState(() {
        isSubmittingReply = false;
      });
    }
  }

  Future<void> _toggleLike({Reply? reply}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      _showErrorSnackBar('You must be logged in to like');
      return;
    }

    final targetId = reply?.id ?? int.parse(widget.postId);

    // Prevent multiple simultaneous like requests
    if (likingPosts.contains(targetId)) return;

    setState(() {
      likingPosts.add(targetId);
    });

    try {
      final userId = authProvider.userData?['id'] ??
          authProvider.userData?['user_id'] ??
          authProvider.userData?['userId'];

      await _forumService.toggleLike(
        postId: reply == null ? int.parse(widget.postId) : null,
        replyId: reply?.id,
        userId: userId,
      );

      // Optimistic update - Update UI immediately
      if (mounted) {
        setState(() {
          if (reply == null && forumPost != null) {
            // Update post like status immediately
            forumPost = forumPost!.copyWith(
              isLikedByUser: !forumPost!.isLikedByUser,
              likeCount: forumPost!.isLikedByUser
                  ? forumPost!.likeCount - 1
                  : forumPost!.likeCount + 1,
            );
          } else if (reply != null) {
            // Update reply like status immediately
            final replyIndex = replies.indexWhere((r) => r.id == reply.id);
            if (replyIndex != -1) {
              replies[replyIndex] = replies[replyIndex].copyWith(
                isLikedByUser: !reply.isLikedByUser,
                likeCount: reply.isLikedByUser
                    ? reply.likeCount - 1
                    : reply.likeCount + 1,
              );
            }
          }
        });
      }

      // Show feedback
      _showSuccessSnackBar(
        reply == null
            ? (forumPost!.isLikedByUser ? 'Post liked!' : 'Post unliked')
            : 'Reply ${replies.firstWhere((r) => r.id == reply.id).isLikedByUser ? "liked!" : "unliked"}',
      );

    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        setState(() {
          if (reply == null && forumPost != null) {
            forumPost = forumPost!.copyWith(
              isLikedByUser: !forumPost!.isLikedByUser,
              likeCount: forumPost!.isLikedByUser
                  ? forumPost!.likeCount - 1
                  : forumPost!.likeCount + 1,
            );
          } else if (reply != null) {
            final replyIndex = replies.indexWhere((r) => r.id == reply.id);
            if (replyIndex != -1) {
              replies[replyIndex] = replies[replyIndex].copyWith(
                isLikedByUser: !replies[replyIndex].isLikedByUser,
                likeCount: replies[replyIndex].isLikedByUser
                    ? replies[replyIndex].likeCount - 1
                    : replies[replyIndex].likeCount + 1,
              );
            }
          }
        });
      }
      _showErrorSnackBar('Failed to toggle like: $e');
    } finally {
      setState(() {
        likingPosts.remove(targetId);
      });
    }
  }

  void _replyToComment(Reply reply) {
    setState(() {
      replyingTo = reply;
    });

    // Focus on reply input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _cancelReply() {
    setState(() {
      replyingTo = null;
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: () {},
        onProfilePressed: () {},
      ),
      body: Column(
        children: [
          // Add custom header with back button
          _buildCustomHeader(),
          Expanded(
            child: _buildContent(),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/forum'), // Navigate back to forum
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discussion',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Feel free to start discussion',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPostDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (forumPost == null) {
      return const Center(
        child: Text('Post not found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPostDetails,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostCard(),
            const SizedBox(height: 20),
            _buildRepliesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Title
            Text(
              forumPost!.title,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Post Content
            Text(
              forumPost!.content ?? '',
              style: GoogleFonts.sora(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Author and Date
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  forumPost!.maskedUsername,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, yyyy • HH:mm').format(forumPost!.createdAt),
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Like and Reply Actions
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: forumPost!.isLikedByUser ? Colors.red[50] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: forumPost!.isLikedByUser ? Colors.red[200]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (likingPosts.contains(int.parse(widget.postId)))
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                forumPost!.isLikedByUser ? Colors.red : Colors.grey,
                              ),
                            ),
                          )
                        else
                          Icon(
                            forumPost!.isLikedByUser ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: forumPost!.isLikedByUser ? Colors.red : Colors.grey[600],
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '${forumPost!.likeCount}',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: forumPost!.isLikedByUser ? Colors.red[700] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${replies.length}',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Replies (${replies.length})',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (replies.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No replies yet. Be the first to reply!',
                style: GoogleFonts.sora(
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          ...replies.map((reply) => _buildReplyCard(reply)).toList(),
      ],
    );
  }

  Widget _buildReplyCard(Reply reply, {int depth = 0}) {
    return Container(
      margin: EdgeInsets.only(
        left: depth * 20.0,
        bottom: 12,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      reply.username.isNotEmpty ? reply.username[0].toUpperCase() : 'U',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              reply.username,
                              style: GoogleFonts.sora(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (reply.roleName == 'advisor') ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                            if (reply.isExpertApproved) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Colors.green,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat('MMM d, yyyy • HH:mm').format(reply.createdAt),
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reply Content
              Text(
                reply.content,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              // Reply Actions
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(reply: reply),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: reply.isLikedByUser ? Colors.red[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: reply.isLikedByUser ? Colors.red[200]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (likingPosts.contains(reply.id))
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  reply.isLikedByUser ? Colors.red : Colors.grey,
                                ),
                              ),
                            )
                          else
                            Icon(
                              reply.isLikedByUser ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: reply.isLikedByUser ? Colors.red : Colors.grey[600],
                            ),
                          const SizedBox(width: 4),
                          Text(
                            '${reply.likeCount}',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: reply.isLikedByUser ? Colors.red[700] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _replyToComment(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reply',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Nested Replies
              if (reply.children != null && reply.children!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...reply.children!.map((childReply) =>
                    _buildReplyCard(childReply, depth: depth + 1)
                ).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Reply to indicator
            if (replyingTo != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Replying to ${replyingTo!.username}',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Reply input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: replyingTo != null
                          ? 'Write your reply...'
                          : 'Share your thoughts...',
                      hintStyle: GoogleFonts.sora(
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isSubmittingReply ? null : _submitReply,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: isSubmittingReply
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
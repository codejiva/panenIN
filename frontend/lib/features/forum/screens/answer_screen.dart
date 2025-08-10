import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/forum/models/forum_model.dart';
import 'package:PanenIn/features/forum/services/forum_service.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AnswerScreen extends StatefulWidget {
  final int? postId; // Make it nullable to handle query parameters

  const AnswerScreen({
    super.key,
    this.postId,
  });

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ForumPost? forumPost;
  bool isLoading = true;
  bool isSubmittingReply = false;
  String? errorMessage;
  int? actualPostId;

  // Mock user data - replace with actual user service
  final int currentUserId = 1; // Replace with actual user ID from auth service

  @override
  void initState() {
    super.initState();
    _initializePostId();
  }

  void _initializePostId() {
    // Get postId from widget parameter or query parameters
    actualPostId = widget.postId;

    // If not provided in constructor, try to get from GoRouter state
    if (actualPostId == null) {
      final state = GoRouterState.of(context);
      final postIdString = state.uri.queryParameters['postId'];
      actualPostId = int.tryParse(postIdString ?? '');
    }

    if (actualPostId != null) {
      _loadForumPost();
    } else {
      setState(() {
        errorMessage = 'Post ID not provided';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadForumPost() async {
    if (actualPostId == null) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final post = await _forumService.getForumPost(actualPostId!);

      if (mounted) {
        setState(() {
          forumPost = post;
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
    if (actualPostId == null) return;

    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your reply'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isSubmittingReply = true;
      });

      final success = await _forumService.createReply(
        postId: actualPostId!,
        content: _replyController.text.trim(),
        userId: currentUserId,
      );

      if (success && mounted) {
        _replyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload the post to show new reply
        await _loadForumPost();

        // Scroll to bottom to show new reply
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingReply = false;
        });
      }
    }
  }

  Future<void> _toggleLike(int? postId, int? replyId) async {
    try {
      await _forumService.toggleLike(
        postId: postId,
        replyId: replyId,
        userId: currentUserId,
      );

      // Reload post to update like counts
      await _loadForumPost();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Like updated!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy | HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        cornerColor: AppColors.secondary,
        onNotificationPressed: () {
          debugPrint('Notification pressed from AnswerScreen');
        },
        onProfilePressed: () {
          debugPrint('Profile pressed from AnswerScreen');
        },
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildContent(),
          ),
          _buildReplySection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ElevatedButton(
                onPressed: () => context.goNamed('forum'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  elevation: 4,
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forumPost?.title ?? 'Loading...',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Question from: ${forumPost?.maskedUsername ?? 'Loading...'}',
                    style: GoogleFonts.sora(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  if (forumPost != null)
                    Text(
                      'Date: ${_formatDateTime(forumPost!.createdAt)}',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadForumPost,
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(0, -3),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildOriginalQuestion(),
            const Divider(thickness: 0.75, color: Colors.black),
            const SizedBox(height: 10),
            _buildRepliesList(),
            const SizedBox(height: 80), // Space for reply input
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalQuestion() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset('assets/images/wheat.svg'),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question from: ${forumPost!.maskedUsername}',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                forumPost!.content,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                softWrap: true,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _toggleLike(forumPost!.id, null),
                    icon: Icon(
                      forumPost!.isLikedByUser == true
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: forumPost!.isLikedByUser == true
                          ? AppColors.primary
                          : Colors.grey[600],
                    ),
                    iconSize: 16,
                  ),
                  Text(
                    forumPost!.displayLikeCount.isNotEmpty
                        ? forumPost!.displayLikeCount
                        : 'Like',
                    style: GoogleFonts.inter(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepliesList() {
    if (forumPost!.replies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No replies yet',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share your thoughts!',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: forumPost!.replies.map((reply) => _buildReplyItem(reply)).toList(),
    );
  }

  Widget _buildReplyItem(Reply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            reply.isAdvisor
                ? 'assets/images/Check_ring.svg'
                : 'assets/images/wheat.svg',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.isAdvisor
                      ? "Doctor's Answer:"
                      : "Community Reply:",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  reply.isAdvisor
                      ? "Responded by: ${reply.advisorDisplayName}"
                      : "Replied by: ${reply.maskedUsername}",
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "Date: ${_formatDateTime(reply.createdAt)}",
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reply.content,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _toggleLike(null, reply.id),
                      icon: Icon(
                        reply.isLikedByUser == true
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: reply.isLikedByUser == true
                            ? AppColors.primary
                            : Colors.grey[600],
                      ),
                      iconSize: 16,
                    ),
                    Text(
                      reply.displayLikeCount.isNotEmpty
                          ? reply.displayLikeCount
                          : 'Like',
                      style: GoogleFonts.inter(fontSize: 10),
                    ),
                  ],
                ),
                if (reply.isApproved) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expert Approved',
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(thickness: 0.5, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplySection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Write your reply...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmittingReply ? null : _submitReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                child: isSubmittingReply
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
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
      ),
    );
  }
}
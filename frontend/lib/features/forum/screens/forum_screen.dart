import 'dart:async';
import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/forum/widgets/ForumPostCard.dart';
import 'package:PanenIn/features/forum/models/forum_model.dart';
import 'package:PanenIn/features/forum/services/forum_service.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();

  // Data variables
  List<ForumPost> forumPosts = [];
  bool isLoading = true;
  String? errorMessage;

  // Auto-refresh variables
  Timer? _refreshTimer;
  bool _isAutoRefreshEnabled = true;

  // Static reference for external access
  static _ForumScreenState? _instance;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _loadForumPosts();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _instance = null;
    super.dispose();
  }

  /// Static method untuk force refresh dari luar
  static void forceRefresh() {
    _instance?._loadForumPosts();
  }

  /// Starts auto-refresh timer (every 1 second for better responsiveness)
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3600), (timer) {
      if (_isAutoRefreshEnabled && mounted && !isLoading) {
        _loadForumPosts(silent: true);
      }
    });
  }

  /// Stops auto-refresh timer
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Toggles auto-refresh on/off
  void _toggleAutoRefresh() {
    setState(() {
      _isAutoRefreshEnabled = !_isAutoRefreshEnabled;
    });

    if (_isAutoRefreshEnabled) {
      _startAutoRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-refresh enabled'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _stopAutoRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-refresh disabled'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  /// Loads forum posts from the API
  /// [silent] - if true, won't show loading indicator (for auto-refresh)
  Future<void> _loadForumPosts({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final posts = await _forumService.getForumPosts();

      if (mounted) {
        setState(() {
          forumPosts = posts;
          if (!silent) {
            isLoading = false;
          }
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          // Handle different error types
          if (e.toString().contains('Network error')) {
            errorMessage = 'No internet connection. Please check your network.';
          } else if (e.toString().contains('timeout')) {
            errorMessage = 'Request timed out. Please try again.';
          } else {
            errorMessage = 'Unable to load forum posts. Please try again.';
          }
          isLoading = false;
        });
      }

      // Log the detailed error for debugging
      debugPrint('Error loading posts: $e');
    }
  }

  /// Refreshes forum posts (for pull-to-refresh)
  Future<void> _refreshPosts() async {
    await _loadForumPosts();
  }

  /// Retries loading posts after an error
  void _retryLoading() {
    _loadForumPosts();
  }

  /// Navigates to ask question screen
  void _navigateToAskQuestion() {
    context.goNamed('ask');
  }

  /// Navigates to post details (if you have this feature)
  void _navigateToPostDetails(ForumPost post) {
    // Implement navigation to post details
    context.goNamed('answer', pathParameters: {'postId': post.id.toString()});
    debugPrint('Navigate to post details: ${post.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: () {
          debugPrint('Notification pressed from ForumScreen');
          // Add notification action here
        },
        onProfilePressed: () {
          debugPrint('Profile pressed from ForumScreen');
          // Add profile action here
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 15),
              _buildContent(),
            ],
          ),
        ),
      ),
      // Add floating action button for auto-refresh toggle
      floatingActionButton: _buildAutoRefreshFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds auto-refresh floating action button
  Widget _buildAutoRefreshFAB() {
    return FloatingActionButton.small(
      onPressed: _toggleAutoRefresh,
      backgroundColor: _isAutoRefreshEnabled ? Colors.green : Colors.grey[400],
      foregroundColor: Colors.white,
      tooltip: _isAutoRefreshEnabled ? 'Disable auto-refresh' : 'Enable auto-refresh',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          _isAutoRefreshEnabled ? Icons.sync : Icons.sync_disabled,
          key: ValueKey(_isAutoRefreshEnabled),
        ),
      ),
    );
  }

  /// Builds the header section with title and Ask button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Community Forum',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isAutoRefreshEnabled) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Where Ideas Grow and Connections Matter!',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 1),
        _buildAskButton(),
      ],
    );
  }

  /// Builds the Ask button
  Widget _buildAskButton() {
    return SizedBox(
      width: 66,
      height: 28,
      child: ElevatedButton(
        onPressed: _navigateToAskQuestion,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/Edit.svg',
               color: AppColors.primary
            ),
            const SizedBox(width: 4),
            Text(
              'Ask',
              style: GoogleFonts.sora(
                fontSize: 13,
                color: AppColors.primary
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content based on current state
  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    } else if (errorMessage != null) {
      return _buildErrorState();
    } else if (forumPosts.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildPostsList();
    }
  }

  /// Builds loading state widget
  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading forum posts...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds error state widget
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Questions Yet',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to ask a question and start the conversation!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _navigateToAskQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/Edit.svg',
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ask a Question'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of forum posts
  Widget _buildPostsList() {
    return Column(
      children: forumPosts.map((post) {
        return Column(
          children: [
            ForumPostCard(
              question: post.title,
              author: post.maskedUsername,
              advisorName: post.advisorName,
              commentCount: post.commentCount,
              createdAt: post.createdAt,
              hasAdvisorResponse: post.hasAdvisorResponse,
              onTap: () => _navigateToPostDetails(post),
            ),
            const SizedBox(height: 15),
          ],
        );
      }).toList(),
    );
  }
}
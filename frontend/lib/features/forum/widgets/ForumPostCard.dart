import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PanenIn/config/constants/colors.dart';
import 'package:intl/intl.dart';

class ForumPostCard extends StatefulWidget {
  final String question;
  final String author;
  final String advisorName;
  final int commentCount;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
  final bool hasAdvisorResponse;
  final VoidCallback? onTap;
  final Future<void> Function()? onLike; // Changed to Future<void> Function()
  final bool isLoading;

  const ForumPostCard({
    super.key,
    required this.question,
    required this.author,
    required this.advisorName,
    required this.commentCount,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
    required this.hasAdvisorResponse,
    this.onTap,
    this.onLike,
    this.isLoading = false,
  });

  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime);
  }

  void _handleLike() async {
    if (_isLikeLoading || widget.onLike == null) return;

    setState(() {
      _isLikeLoading = true;
    });

    // Animate heart if liked
    if (!widget.isLiked) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    try {
      await widget.onLike!(); // Now properly handles async function
    } catch (e) {
      // Error handling is done in parent widget
    } finally {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question title
              Text(
                widget.question,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Author info
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Asked by: ${widget.author}',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                _formatDateTime(widget.createdAt),
                style: GoogleFonts.sora(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),

              // Actions row - Like, Comment, Status
              Row(
                children: [
                  // Like button
                  GestureDetector(
                    onTap: _handleLike,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isLiked ? Colors.red[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLikeLoading)
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isLiked ? Colors.red : Colors.grey,
                                ),
                              ),
                            )
                          else
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Icon(
                                    widget.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 14,
                                    color: widget.isLiked ? Colors.red : Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.likeCount}',
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: widget.isLiked ? Colors.red[700] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Comment count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.commentCount}',
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Advisor response status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.hasAdvisorResponse
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.hasAdvisorResponse
                              ? Icons.check_circle_outline
                              : Icons.access_time,
                          size: 12,
                          color: widget.hasAdvisorResponse
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.hasAdvisorResponse ? 'Answered' : 'Waiting',
                          style: GoogleFonts.sora(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: widget.hasAdvisorResponse
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Advisor name if answered
              if (widget.hasAdvisorResponse) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Answered by: ${widget.advisorName}',
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Loading overlay
              if (widget.isLoading) ...[
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
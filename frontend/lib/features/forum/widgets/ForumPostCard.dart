// File: lib/features/forum/widgets/ForumPostCard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PanenIn/config/constants/colors.dart';
import 'package:intl/intl.dart';

class ForumPostCard extends StatelessWidget {
  final String question;
  final String author;
  final String advisorName;
  final int commentCount;
  final DateTime createdAt;
  final bool hasAdvisorResponse;
  final VoidCallback? onTap;

  const ForumPostCard({
    super.key,
    required this.question,
    required this.author,
    required this.advisorName,
    required this.commentCount,
    required this.createdAt,
    required this.hasAdvisorResponse,
    this.onTap,
  });

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question title
              Text(
                question,
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
                  Text(
                    'Asked by: $author',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                _formatDateTime(createdAt),
                style: GoogleFonts.sora(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),

              // Status and stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Advisor response status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasAdvisorResponse
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasAdvisorResponse
                              ? Icons.check_circle_outline
                              : Icons.access_time,
                          size: 14,
                          color: hasAdvisorResponse
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasAdvisorResponse
                              ? 'Answered'
                              : 'Waiting',
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: hasAdvisorResponse
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Comment count
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$commentCount ${commentCount == 1 ? 'reply' : 'replies'}',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Advisor name if answered
              if (hasAdvisorResponse) ...[
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
                        'Answered by: $advisorName',
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
            ],
          ),
        ),
      ),
    );
  }
}
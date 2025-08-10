class ForumPost {
  final int id;
  final String title;
  final String? content;
  final DateTime createdAt;
  final String maskedUsername;
  final String username;
  final String advisorName;
  final int commentCount;
  final int likeCount;
  final bool hasAdvisorResponse;
  final bool isLikedByUser;
  final List<Reply>? replies;
  final int userId;
  final String roleName;

  ForumPost({
    required this.id,
    required this.title,
    this.content,
    required this.createdAt,
    required this.maskedUsername,
    required this.username,
    required this.advisorName,
    required this.commentCount,
    required this.likeCount,
    required this.hasAdvisorResponse,
    required this.isLikedByUser,
    this.replies,
    required this.userId,
    required this.roleName,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    // Handle replies if present
    List<Reply>? repliesList;
    if (json['replies'] != null) {
      try {
        repliesList = (json['replies'] as List)
            .map((replyJson) => Reply.fromJson(replyJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing replies: $e');
        repliesList = null;
      }
    }

    // Calculate comment count from replies length
    final commentCount = repliesList?.length ??
        json['comment_count'] ??
        json['reply_count'] ??
        0;

    return ForumPost(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      maskedUsername: json['masked_username'] ??
          json['username'] ??
          'Anonymous User',
      username: json['username'] ?? 'Anonymous User',
      advisorName: json['advisor_name'] ??
          json['adviser_name'] ??
          'No advisor yet',
      commentCount: commentCount,
      likeCount: json['like_count'] ?? 0,
      hasAdvisorResponse: json['has_advisor_response'] ??
          json['has_adviser_response'] ??
          _checkHasAdvisorResponse(repliesList),
      isLikedByUser: json['is_liked_by_user'] ?? false,
      replies: repliesList,
      userId: json['user_id'] ?? json['author_id'] ?? 0,
      roleName: json['role_name'] ?? 'user',
    );
  }

  // Helper method to check if any reply is from advisor
  static bool _checkHasAdvisorResponse(List<Reply>? replies) {
    if (replies == null || replies.isEmpty) return false;
    return replies.any((reply) =>
    reply.roleName == 'advisor' ||
        reply.roleName == 'adviser' ||
        reply.isExpertApproved
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'masked_username': maskedUsername,
      'advisor_name': advisorName,
      'comment_count': commentCount,
      'like_count': likeCount,
      'has_advisor_response': hasAdvisorResponse,
      'is_liked_by_user': isLikedByUser,
      'user_id': userId,
      'role_name': roleName,
      if (replies != null)
        'replies': replies!.map((reply) => reply.toJson()).toList(),
    };
  }

  // Create a copy with updated values
  ForumPost copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? maskedUsername,
    String? username,
    String? advisorName,
    int? commentCount,
    int? likeCount,
    bool? hasAdvisorResponse,
    bool? isLikedByUser,
    List<Reply>? replies,
    int? userId,
    String? roleName,
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      maskedUsername: maskedUsername ?? this.maskedUsername,
      username: username ?? this.username,
      advisorName: advisorName ?? this.advisorName,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      hasAdvisorResponse: hasAdvisorResponse ?? this.hasAdvisorResponse,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      replies: replies ?? this.replies,
      userId: userId ?? this.userId,
      roleName: roleName ?? this.roleName,
    );
  }
}

class Reply {
  final int id;
  final String content;
  final DateTime createdAt;
  final String username;
  final String roleName;
  final int likeCount;
  final bool isLikedByUser;
  final bool isExpertApproved;
  final bool isOriginalPoster;
  final int? parentReplyId;
  final int userId;
  final List<Reply>? children;

  Reply({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.username,
    required this.roleName,
    required this.likeCount,
    required this.isLikedByUser,
    required this.isExpertApproved,
    required this.isOriginalPoster,
    this.parentReplyId,
    required this.userId,
    this.children,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    // Handle nested children replies
    List<Reply>? childrenList;
    if (json['children'] != null) {
      try {
        childrenList = (json['children'] as List)
            .map((childJson) => Reply.fromJson(childJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing child replies: $e');
        childrenList = null;
      }
    }

    return Reply(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      username: json['username'] ?? 'Anonymous User',
      roleName: json['role_name'] ?? 'user',
      likeCount: json['like_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
      isExpertApproved: json['is_expert_approved'] == 1 || json['is_expert_approved'] == true,
      isOriginalPoster: json['is_op'] == 1 || json['is_original_poster'] == true,
      parentReplyId: json['parent_reply_id'],
      userId: json['user_id'] ?? 0,
      children: childrenList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'role_name': roleName,
      'like_count': likeCount,
      'is_liked_by_user': isLikedByUser,
      'is_expert_approved': isExpertApproved,
      'is_op': isOriginalPoster ? 1 : 0,
      'parent_reply_id': parentReplyId,
      'user_id': userId,
      if (children != null)
        'children': children!.map((child) => child.toJson()).toList(),
    };
  }

  // Create a copy with updated values
  Reply copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    String? username,
    String? roleName,
    int? likeCount,
    bool? isLikedByUser,
    bool? isExpertApproved,
    bool? isOriginalPoster,
    int? parentReplyId,
    int? userId,
    List<Reply>? children,
  }) {
    return Reply(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      roleName: roleName ?? this.roleName,
      likeCount: likeCount ?? this.likeCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isExpertApproved: isExpertApproved ?? this.isExpertApproved,
      isOriginalPoster: isOriginalPoster ?? this.isOriginalPoster,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      userId: userId ?? this.userId,
      children: children ?? this.children,
    );
  }

  // Check if this reply is a top-level reply (no parent)
  bool get isTopLevel => parentReplyId == null;

  // Check if this reply has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  // Get total reply count including nested children
  int get totalReplyCount {
    if (children == null || children!.isEmpty) return 0;

    int count = children!.length;
    for (final child in children!) {
      count += child.totalReplyCount;
    }
    return count;
  }
}
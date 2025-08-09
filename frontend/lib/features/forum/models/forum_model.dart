// File: lib/features/forum/models/forum_model.dart

// Enum for user roles in the forum
enum UserRole {
  farmer('farmer'),
  advisor('advisor');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return UserRole.farmer;
      case 'advisor':
        return UserRole.advisor;
      default:
        return UserRole.farmer; // Default to farmer if unknown role
    }
  }

  bool get isAdvisor => this == UserRole.advisor;
  bool get isFarmer => this == UserRole.farmer;
}

class ForumPost {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String username;
  final String roleName;
  final List<Reply> replies;
  final int? likeCount;
  final bool? isLikedByUser;

  final UserRole userRole;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.username,
    required this.roleName,
    required this.replies,
    this.likeCount,
    this.isLikedByUser,
  }) : userRole = UserRole.fromString(roleName);

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'],
      roleName: json['role_name'],
      replies: (json['replies'] as List? ?? [])
          .map((reply) => Reply.fromJson(reply))
          .toList(),
      likeCount: json['like_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'role_name': roleName,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'like_count': likeCount,
      'is_liked_by_user': isLikedByUser,
    };
  }

  // Helper method to get masked username
  String get maskedUsername {
    if (username.length <= 3) {
      return username;
    }
    return '${username.substring(0, 2)}${'*' * (username.length - 3)}${username.substring(username.length - 1)}';
  }

  // Helper method to check if there's an advisor response
  bool get hasAdvisorResponse {
    return replies.any((reply) => reply.isAdvisor);
  }

  // Helper method to get advisor name from replies
  String get advisorName {
    if (replies.isEmpty) {
      return 'Waiting for advisor response';
    }

    // Look for advisor replies first
    final advisorReply = replies.firstWhere(
          (reply) => reply.isAdvisor,
      orElse: () => replies.first,
    );

    return advisorReply.isAdvisor
        ? advisorReply.advisorDisplayName
        : 'Waiting for advisor response';
  }

  // Helper method to get comment count
  int get commentCount => replies.length;

  // Helper method to get display like count
  String get displayLikeCount {
    if (likeCount == null || likeCount == 0) return '';
    if (likeCount == 1) return '1 like';
    return '$likeCount likes';
  }
}

class Reply {
  final int id;
  final String content;
  final DateTime createdAt;
  final String username;
  final String roleName;
  final int? likeCount;
  final bool? isLikedByUser;
  final bool? isExpertApproved;
  final List<Reply>? children; // For nested replies

  final UserRole userRole;

  Reply({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.username,
    required this.roleName,
    this.likeCount,
    this.isLikedByUser,
    this.isExpertApproved,
    this.children,
  }) : userRole = UserRole.fromString(roleName);

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'],
      roleName: json['role_name'],
      likeCount: json['like_count'],
      isLikedByUser: json['is_liked_by_user'],
      isExpertApproved: json['is_expert_approved'],
      children: (json['children'] as List? ?? [])
          .map((child) => Reply.fromJson(child))
          .toList(),
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
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  // Helper method to check if this reply is from an advisor
  bool get isAdvisor => userRole.isAdvisor;

  // Helper method to get advisor display name
  String get advisorDisplayName {
    if (isAdvisor) {
      return 'Dr. Agr. Siti Masaroh'; // Default advisor name
    }
    return maskedUsername; // Return masked username for farmers
  }

  // Helper method to get masked username
  String get maskedUsername {
    if (username.length <= 3) {
      return username;
    }
    return '${username.substring(0, 2)}${'*' * (username.length - 3)}${username.substring(username.length - 1)}';
  }

  // Helper method to get display like count
  String get displayLikeCount {
    if (likeCount == null || likeCount == 0) return '';
    if (likeCount == 1) return '1 like';
    return '$likeCount likes';
  }

  // Helper method to check if reply is approved
  bool get isApproved => isExpertApproved == true;
}
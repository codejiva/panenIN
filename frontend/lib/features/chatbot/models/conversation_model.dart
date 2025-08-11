import 'package:PanenIn/features/chatbot/models/chatroom_item_model.dart';
import 'package:flutter/animation.dart';

class Conversation {
  final String id;
  final String title;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.title,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory for backend response format
  factory Conversation.fromBackendJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: null, // Backend doesn't return this directly
      lastMessageTime: null, // Backend doesn't return this directly
      unreadCount: 0, // Backend doesn't return this directly
      userId: '', // We don't get this from the response
      createdAt: DateTime.now(), // Backend doesn't return this
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Legacy factory for compatibility
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChatroomItem toChatroomItem() {
    return ChatroomItem(
      id: id,
      title: title,
      lastMessage: lastMessage ?? 'Start a conversation',
      timestamp: _formatTimestamp(updatedAt),
      isAI: true, // All conversations with backend are AI
      unreadCount: unreadCount,
      isOnline: true,
      avatarColor: const Color(0xFF48BB78),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 1) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }
}
import 'dart:ui';

class ChatroomItem {
  final String id;
  final String title;
  final String lastMessage;
  final String timestamp;
  final bool isAI;
  final int unreadCount;
  final bool isOnline;
  final Color avatarColor;

  ChatroomItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.isAI,
    required this.unreadCount,
    required this.isOnline,
    required this.avatarColor,
  });

  ChatroomItem copyWith({
    String? id,
    String? title,
    String? lastMessage,
    String? timestamp,
    bool? isAI,
    int? unreadCount,
    bool? isOnline,
    Color? avatarColor,
  }) {
    return ChatroomItem(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      isAI: isAI ?? this.isAI,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'isAI': isAI,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'avatarColor': avatarColor.value,
    };
  }

  factory ChatroomItem.fromJson(Map<String, dynamic> json) {
    return ChatroomItem(
      id: json['id'] as String,
      title: json['title'] as String,
      lastMessage: json['lastMessage'] as String,
      timestamp: json['timestamp'] as String,
      isAI: json['isAI'] as bool,
      unreadCount: json['unreadCount'] as int,
      isOnline: json['isOnline'] as bool,
      avatarColor: Color(json['avatarColor'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatroomItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatroomItem(id: $id, title: $title, isAI: $isAI, unreadCount: $unreadCount)';
  }
}
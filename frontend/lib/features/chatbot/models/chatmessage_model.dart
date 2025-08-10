class ChatMessage {
  final String id;
  final bool isUser;
  final String message;
  final String timestamp;
  final bool hasImage;
  final String? imageUrl;
  final String? localImagePath; // For local images before upload
  final bool hasAudio;
  final String? audioDuration;
  final ChatDiagnosis? diagnosis;
  final MessageStatus status;
  final String? conversationId;

  ChatMessage({
    String? id,
    required this.isUser,
    required this.message,
    required this.timestamp,
    this.hasImage = false,
    this.imageUrl,
    this.localImagePath,
    this.hasAudio = false,
    this.audioDuration,
    this.diagnosis,
    this.status = MessageStatus.sent,
    this.conversationId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  ChatMessage copyWith({
    String? id,
    bool? isUser,
    String? message,
    String? timestamp,
    bool? hasImage,
    String? imageUrl,
    String? localImagePath,
    bool? hasAudio,
    String? audioDuration,
    ChatDiagnosis? diagnosis,
    MessageStatus? status,
    String? conversationId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      hasImage: hasImage ?? this.hasImage,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      hasAudio: hasAudio ?? this.hasAudio,
      audioDuration: audioDuration ?? this.audioDuration,
      diagnosis: diagnosis ?? this.diagnosis,
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUser': isUser,
      'message': message,
      'timestamp': timestamp,
      'hasImage': hasImage,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'hasAudio': hasAudio,
      'audioDuration': audioDuration,
      'diagnosis': diagnosis?.toJson(),
      'status': status.toString().split('.').last,
      'conversationId': conversationId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      isUser: json['isUser'] as bool,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      hasImage: json['hasImage'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
      hasAudio: json['hasAudio'] as bool? ?? false,
      audioDuration: json['audioDuration'] as String?,
      diagnosis: json['diagnosis'] != null
          ? ChatDiagnosis.fromJson(json['diagnosis'])
          : null,
      status: MessageStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      conversationId: json['conversationId'] as String?,
    );
  }

  // Create from backend message format
  factory ChatMessage.fromBackendMessage(Map<String, dynamic> json, {bool isUser = false}) {
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: isUser,
      message: json['content'] as String? ?? '',
      timestamp: _formatTimestamp(json['created_at'] as String?),
      conversationId: json['conversation_id'] as String?,
      status: MessageStatus.sent,
    );
  }

  static String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return _getCurrentTime();
    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return _getCurrentTime();
    }
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}

enum MessageStatus {
  sending,
  sent,
  failed,
}

class ChatDiagnosis {
  final String title;
  final List<String> symptoms;
  final List<String> management;

  ChatDiagnosis({
    required this.title,
    required this.symptoms,
    required this.management,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'symptoms': symptoms,
      'management': management,
    };
  }

  factory ChatDiagnosis.fromJson(Map<String, dynamic> json) {
    return ChatDiagnosis(
      title: json['title'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      management: List<String>.from(json['management'] as List),
    );
  }
}
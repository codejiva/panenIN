class ChatMessage {
  final String id;
  final bool isUser;
  final String message;
  final String timestamp;
  final bool hasImage;
  final String? imageUrl;
  final String? localImagePath;
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

  // Optimized copyWith - only create new instance if values actually change
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
    // Check if any value actually changed to avoid unnecessary object creation
    if (id == this.id &&
        isUser == this.isUser &&
        message == this.message &&
        timestamp == this.timestamp &&
        hasImage == this.hasImage &&
        imageUrl == this.imageUrl &&
        localImagePath == this.localImagePath &&
        hasAudio == this.hasAudio &&
        audioDuration == this.audioDuration &&
        diagnosis == this.diagnosis &&
        status == this.status &&
        conversationId == this.conversationId) {
      return this; // Return same instance if nothing changed
    }

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

  // Lazy loading toJson - only convert when needed
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'isUser': isUser,
      'message': message,
      'timestamp': timestamp,
      'status': status.toString().split('.').last,
    };

    // Only add optional fields if they have values
    if (hasImage) json['hasImage'] = hasImage;
    if (imageUrl != null) json['imageUrl'] = imageUrl;
    if (localImagePath != null) json['localImagePath'] = localImagePath;
    if (hasAudio) json['hasAudio'] = hasAudio;
    if (audioDuration != null) json['audioDuration'] = audioDuration;
    if (diagnosis != null) json['diagnosis'] = diagnosis!.toJson();
    if (conversationId != null) json['conversationId'] = conversationId;

    return json;
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

  // Optimized factory for backend messages
  factory ChatMessage.fromBackendMessage(Map<String, dynamic> json, {bool isUser = false}) {
    final timestamp = json['created_at'] as String?;
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: isUser,
      message: json['content'] as String? ?? '',
      timestamp: timestamp != null ? _formatTimestamp(timestamp) : _getCurrentTime(),
      conversationId: json['conversation_id'] as String?,
      status: MessageStatus.sent,
    );
  }

  // Cached timestamp formatting
  static final Map<String, String> _timestampCache = <String, String>{};

  static String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return _getCurrentTime();

    // Check cache first
    if (_timestampCache.containsKey(timestamp)) {
      return _timestampCache[timestamp]!;
    }

    try {
      final dateTime = DateTime.parse(timestamp);
      final formatted = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

      // Cache the result (limit cache size to prevent memory leaks)
      if (_timestampCache.length > 100) {
        _timestampCache.clear();
      }
      _timestampCache[timestamp] = formatted;

      return formatted;
    } catch (e) {
      return _getCurrentTime();
    }
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // Optimized equality and hashCode for better performance in lists
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum MessageStatus {
  sending,
  sent,
  failed,
}

// Optimized diagnosis model
class ChatDiagnosis {
  final String title;
  final List<String> symptoms;
  final List<String> management;

  ChatDiagnosis({
    required this.title,
    required this.symptoms,
    required this.management,
  });

  // Use const constructor when possible
  const ChatDiagnosis.empty()
      : title = '',
        symptoms = const [],
        management = const [];

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
      symptoms: List<String>.from(json['symptoms'] as List? ?? []),
      management: List<String>.from(json['management'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatDiagnosis && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}
class ChatMessage {
  final bool isUser;
  final String message;
  final String timestamp;
  final bool hasImage;
  final String? imageUrl;
  final bool hasAudio;
  final String? audioDuration;
  final ChatDiagnosis? diagnosis;

  ChatMessage({
    required this.isUser,
    required this.message,
    required this.timestamp,
    this.hasImage = false,
    this.imageUrl,
    this.hasAudio = false,
    this.audioDuration,
    this.diagnosis,
  });
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
}
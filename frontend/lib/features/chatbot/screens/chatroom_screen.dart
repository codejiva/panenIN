import 'package:flutter/material.dart';
import 'package:PanenIn/models/chatmessage_model.dart';
import 'package:PanenIn/features/chatbot/providers/AudioWaveformPainter.dart';
import 'package:go_router/go_router.dart';

class PanenAIChatScreen extends StatefulWidget {
  const PanenAIChatScreen({super.key});

  @override
  _PanenAIChatScreenState createState() => _PanenAIChatScreenState();
}

class _PanenAIChatScreenState extends State<PanenAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMessage() {
    // Simulate initial AI response
    setState(() {
      _messages.addAll([
        ChatMessage(
          isUser: true,
          message: "What is happening to my rice plants?",
          timestamp: "16:30",
          hasImage: true,
          imageUrl: "assets/images/rice_disease.jpg", // placeholder
        ),
        ChatMessage(
          isUser: false,
          message: "The rice plant disease shown is Brown Spot, caused by the fungus Bipolaris oryzae.",
          timestamp: "16:30",
          hasAudio: true,
          audioDuration: "1:24",
          diagnosis: ChatDiagnosis(
            title: "Diagnosis:",
            symptoms: [
              "Brown to dark brown round or oval spots on leaves.",
              "Severe infection leads to leaf drying and yield loss."
            ],
            management: [
              "Use healthy, resistant seeds.",
              "Apply balanced fertilizer (especially nitrogen and phosphorus)."
            ],
          ),
        ),
      ]);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        isUser: true,
        message: _messageController.text.trim(),
        timestamp: _getCurrentTime(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response after delay
    Future.delayed(const Duration(seconds: 2), () {
      _simulateAIResponse();
    });
  }

  void _simulateAIResponse() {
    setState(() {
      _messages.add(ChatMessage(
        isUser: false,
        message: "I understand your concern. Could you provide more details about the symptoms you're observing?",
        timestamp: _getCurrentTime(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.go('/chatbot'),
      ),
      title: const Text(
        'Panen AI',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF48BB78),
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF48BB78)
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.hasImage) _buildImageContainer(),
                      if (message.hasAudio) _buildAudioPlayer(message),
                      Text(
                        message.message,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      if (message.diagnosis != null)
                        _buildDiagnosisSection(message.diagnosis!),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.timestamp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (message.isUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/rice_plants.jpg', // placeholder
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isAudioPlaying = !_isAudioPlaying;
              });
            },
            child: Icon(
              _isAudioPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF48BB78),
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 24,
              child: CustomPaint(
                painter: AudioWaveformPainter(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message.audioDuration ?? "0:00",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF48BB78),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.done_all,
            size: 12,
            color: Color(0xFF48BB78),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection(ChatDiagnosis diagnosis) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diagnosis.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...diagnosis.symptoms.map((symptom) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(symptom, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
          const SizedBox(height: 8),
          const Text(
            "Management:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ...diagnosis.management.map((management) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(management, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Handle add attachment
            },
            icon: const Icon(Icons.add, color: Colors.grey),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle camera
            },
            icon: const Icon(Icons.camera_alt, color: Colors.grey),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isRecording = !_isRecording;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
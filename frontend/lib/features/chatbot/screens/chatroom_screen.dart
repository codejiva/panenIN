// lib/features/chatbot/screens/enhanced_chat_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:PanenIn/features/chatbot/models/chatmessage_model.dart';
import 'package:PanenIn/features/chatbot/services/chatbot_service.dart';
import 'package:PanenIn/features/chatbot/providers/AudioWaveformPainter.dart';

class PanenAIChatScreen extends StatefulWidget {
  final String? conversationId;

  const PanenAIChatScreen({
    super.key,
    this.conversationId,
  });

  @override
  _EnhancedPanenAIChatScreenState createState() => _EnhancedPanenAIChatScreenState();
}

class _EnhancedPanenAIChatScreenState extends State<PanenAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isRecording = false;
  bool _isAudioPlaying = false;
  bool _isLoading = false;
  String? _currentConversationId;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
    _loadConversationHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversationHistory() async {
    if (_currentConversationId == null) return;

    setState(() => _isLoading = true);

    try {
      final messages = await ChatService.getConversationHistory(
        context,
        _currentConversationId!,
      );
      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Failed to load conversation history: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();

    // Validate input
    if (messageText.isEmpty && _selectedImage == null) return;

    // Create user message
    final userMessage = ChatMessage(
      isUser: true,
      message: messageText.isNotEmpty ? messageText : '[Image]',
      timestamp: _getCurrentTime(),
      hasImage: _selectedImage != null,
      localImagePath: _selectedImage?.path,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    final imageToSend = _selectedImage;
    _selectedImage = null;
    _scrollToBottom();

    try {
      final ChatResponse response;

      if (_currentConversationId == null) {
        // Start new conversation
        response = await ChatService.startNewChat(
          context,
          message: messageText.isNotEmpty ? messageText : null,
          imageFile: imageToSend,
        );
        _currentConversationId = response.conversationId;
      } else {
        // Continue existing conversation
        response = await ChatService.continueChat(
          context,
          conversationId: _currentConversationId!,
          message: messageText.isNotEmpty ? messageText : null,
          imageFile: imageToSend,
        );
      }

      // Update user message status
      final updatedUserMessage = userMessage.copyWith(
        status: MessageStatus.sent,
        conversationId: _currentConversationId,
      );

      // Create AI response message
      final aiMessage = response.toAIMessage().copyWith(
        conversationId: _currentConversationId,
      );

      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == userMessage.id);
        if (index != -1) {
          _messages[index] = updatedUserMessage;
        }
        _messages.add(aiMessage);
      });

      _scrollToBottom();
    } catch (e) {
      // Update user message status to failed
      final failedMessage = userMessage.copyWith(status: MessageStatus.failed);
      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == userMessage.id);
        if (index != -1) {
          _messages[index] = failedMessage;
        }
      });

      _showErrorSnackBar('Failed to send message: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF48BB78)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF48BB78)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _retryMessage(ChatMessage message) async {
    if (message.status != MessageStatus.failed) return;

    // Update message status to sending
    final retryMessage = message.copyWith(status: MessageStatus.sending);
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == message.id);
      if (index != -1) {
        _messages[index] = retryMessage;
      }
      _isLoading = true;
    });

    try {
      final ChatResponse response;
      File? imageFile;

      // Check if message has image
      if (message.localImagePath != null) {
        imageFile = File(message.localImagePath!);
      }

      if (_currentConversationId == null) {
        response = await ChatService.startNewChat(
          context,
          message: message.message.isNotEmpty && message.message != '[Image]' ? message.message : null,
          imageFile: imageFile,
        );
        _currentConversationId = response.conversationId;
      } else {
        response = await ChatService.continueChat(
          context,
          conversationId: _currentConversationId!,
          message: message.message.isNotEmpty && message.message != '[Image]' ? message.message : null,
          imageFile: imageFile,
        );
      }

      // Update message status to sent
      final sentMessage = retryMessage.copyWith(
        status: MessageStatus.sent,
        conversationId: _currentConversationId,
      );

      // Create AI response
      final aiMessage = response.toAIMessage().copyWith(
        conversationId: _currentConversationId,
      );

      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == retryMessage.id);
        if (index != -1) {
          _messages[index] = sentMessage;
        }
        _messages.add(aiMessage);
      });

      _scrollToBottom();
    } catch (e) {
      // Update message status back to failed
      final failedMessage = retryMessage.copyWith(status: MessageStatus.failed);
      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == retryMessage.id);
        if (index != -1) {
          _messages[index] = failedMessage;
        }
      });

      _showErrorSnackBar('Failed to retry message: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isLoading && _messages.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _buildMessageList(),
            ),
          if (_selectedImage != null) _buildSelectedImagePreview(),
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
      actions: [
        if (_currentConversationId != null)
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showConversationOptions,
          ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF48BB78).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 60,
              color: Color(0xFF48BB78),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about farming, plant diseases,\nor send me a photo for analysis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        curve: Curves.easeInOut,
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF48BB78).withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                GestureDetector(
                  onTap: message.status == MessageStatus.failed
                      ? () => _retryMessage(message)
                      : null,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF48BB78)
                          : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(16),
                      border: message.status == MessageStatus.failed
                          ? Border.all(color: Colors.red, width: 1)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.hasImage && message.localImagePath != null)
                          _buildMessageImage(message.localImagePath!),
                        if (message.hasAudio) _buildAudioPlayer(message),
                        if (message.message.isNotEmpty && message.message != '[Image]')
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
                      _buildMessageStatusIcon(message.status),
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

  Widget _buildMessageImage(String imagePath) {
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
        child: Image.file(
          File(imagePath),
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

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey[600],
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error,
          size: 16,
          color: Colors.red[600],
        );
    }
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

  Widget _buildSelectedImagePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Image',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Ready to send',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
            icon: Icon(Icons.close, color: Colors.grey[600]),
          ),
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
            onPressed: _showImageSourceActionSheet,
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
                enabled: !_isLoading,
              ),
            ),
          ),
          IconButton(
            onPressed: _showImageSourceActionSheet,
            icon: const Icon(Icons.camera_alt, color: Colors.grey),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _canSendMessage() ? const Color(0xFF48BB78) : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedImage != null || _messageController.text.trim().isNotEmpty
                    ? Icons.send
                    : Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSendMessage() {
    return (_messageController.text.trim().isNotEmpty || _selectedImage != null) && !_isLoading;
  }

  void _showConversationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Conversation'),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _deleteConversation() async {
    if (_currentConversationId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ChatService.deleteConversation(context, _currentConversationId!);
        if (mounted) {
          context.go('/chatbot');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to delete conversation: ${e.toString()}');
      }
    }
  }
}
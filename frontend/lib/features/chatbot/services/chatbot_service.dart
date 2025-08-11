import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:PanenIn/features/chatbot/models/chatmessage_model.dart';
import 'package:PanenIn/features/chatbot/models/conversation_model.dart';
import 'package:PanenIn/features/auth/services/auth_service.dart';

class ChatService {
  static const String baseUrl = 'https://panen-in-teal.vercel.app';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  // Cache untuk mengurangi API calls
  static final Map<String, List<ChatMessage>> _messageCache = {};
  static final Map<String, List<Conversation>> _conversationCache = {};
  static Timer? _cacheCleanupTimer;

  // HTTP client dengan connection pooling
  static final http.Client _httpClient = http.Client();

  // Initialize service
  static void initialize() {
    // Cleanup cache setiap 5 menit untuk mencegah memory leak
    _cacheCleanupTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _cleanupCache();
    });
  }

  // Dispose service
  static void dispose() {
    _cacheCleanupTimer?.cancel();
    _httpClient.close();
    _messageCache.clear();
    _conversationCache.clear();
  }

  static void _cleanupCache() {
    // Keep only last 50 conversations and 100 messages per conversation
    if (_conversationCache.length > 50) {
      final keys = _conversationCache.keys.toList();
      keys.take(keys.length - 50).forEach(_conversationCache.remove);
    }

    _messageCache.forEach((key, messages) {
      if (messages.length > 100) {
        _messageCache[key] = messages.takeLast(50).toList();
      }
    });
  }

  // Optimized auth methods
  static AuthProvider _getAuthProvider(BuildContext context) {
    return context.read<AuthProvider>(); // Using read instead of Provider.of for better performance
  }

  static String _getUserId(BuildContext context) {
    final authProvider = _getAuthProvider(context);
    final userData = authProvider.userData;

    return userData?['id']?.toString() ??
        userData?['user_id']?.toString() ??
        userData?['userId']?.toString() ??
        userData?['_id']?.toString() ??
        'unknown_user';
  }

  static String? _getToken(BuildContext context) {
    final authProvider = _getAuthProvider(context);
    return authProvider.token;
  }

  // Cached headers to avoid recreation
  static Map<String, String>? _cachedHeaders;
  static String? _cachedToken;

  static Map<String, String> _getHeaders(BuildContext context) {
    final token = _getToken(context);

    // Return cached headers if token hasn't changed
    if (_cachedToken == token && _cachedHeaders != null) {
      return _cachedHeaders!;
    }

    _cachedToken = token;
    _cachedHeaders = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      _cachedHeaders!['Authorization'] = 'Bearer $token';
    }

    return _cachedHeaders!;
  }

  static Map<String, String> _getMultipartHeaders(BuildContext context) {
    final token = _getToken(context);
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static bool _isAuthenticated(BuildContext context) {
    final authProvider = _getAuthProvider(context);
    return authProvider.isLoggedIn && authProvider.token != null;
  }

  // Optimized message sending with connection reuse
  static Future<ChatResponse> startNewChat(
      BuildContext context, {
        String? message,
        File? imageFile,
      }) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    try {
      final userId = _getUserId(context);

      if (imageFile != null) {
        return await _sendMessageWithFile(
          context,
          message: message,
          file: imageFile,
          userId: userId,
        );
      } else {
        return await _sendTextMessage(
          context,
          message: message!,
          userId: userId,
        );
      }
    } catch (e) {
      throw ChatException('Failed to start new chat: ${e.toString()}');
    }
  }

  static Future<ChatResponse> continueChat(
      BuildContext context, {
        required String conversationId,
        String? message,
        File? imageFile,
      }) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    try {
      final userId = _getUserId(context);

      if (imageFile != null) {
        return await _sendMessageWithFile(
          context,
          conversationId: conversationId,
          message: message,
          file: imageFile,
          userId: userId,
        );
      } else {
        return await _sendTextMessage(
          context,
          conversationId: conversationId,
          message: message!,
          userId: userId,
        );
      }
    } catch (e) {
      throw ChatException('Failed to continue chat: ${e.toString()}');
    }
  }

  // Optimized HTTP requests with timeout and connection reuse
  static Future<ChatResponse> _sendTextMessage(
      BuildContext context, {
        String? conversationId,
        required String message,
        required String userId,
      }) async {
    final url = conversationId != null
        ? '$baseUrl/api/chat/$conversationId/message'
        : '$baseUrl/api/chat/start';

    final body = jsonEncode({
      'message': message,
      'userId': userId,
    });

    try {
      final response = await _httpClient
          .post(
        Uri.parse(url),
        headers: _getHeaders(context),
        body: body,
      )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Update cache if this is a new conversation
        if (conversationId != null) {
          _invalidateConversationCache();
        }

        return ChatResponse.fromJson(data);
      } else {
        throw ChatException('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw ChatException('Request timeout. Please check your connection.');
    } catch (e) {
      throw ChatException('Network error: ${e.toString()}');
    }
  }

  static Future<ChatResponse> _sendMessageWithFile(
      BuildContext context, {
        String? conversationId,
        String? message,
        required File file,
        required String userId,
      }) async {
    final url = conversationId != null
        ? '$baseUrl/api/chat/$conversationId/message'
        : '$baseUrl/api/chat/start';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_getMultipartHeaders(context));

      if (message != null && message.isNotEmpty) {
        request.fields['message'] = message;
      }
      request.fields['userId'] = userId;

      // Compress image if needed
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(_defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (conversationId != null) {
          _invalidateConversationCache();
        }

        return ChatResponse.fromJson(data);
      } else {
        throw ChatException('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw ChatException('Upload timeout. Please check your connection.');
    } catch (e) {
      throw ChatException('Upload error: ${e.toString()}');
    }
  }

  // Cached conversation history
  static Future<List<ChatMessage>> getConversationHistory(
      BuildContext context,
      String conversationId,
      ) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    // Check cache first
    if (_messageCache.containsKey(conversationId)) {
      return _messageCache[conversationId]!;
    }

    try {
      final response = await _httpClient
          .get(
        Uri.parse('$baseUrl/api/chat/$conversationId/messages'),
        headers: _getHeaders(context),
      )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body);

        final chatMessages = messages.map((messageJson) {
          final role = messageJson['role'] as String;
          return ChatMessage.fromBackendMessage(
            messageJson,
            isUser: role == 'user',
          );
        }).toList();

        // Cache the result
        _messageCache[conversationId] = chatMessages;

        return chatMessages;
      } else {
        throw ChatException('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw ChatException('Request timeout. Please check your connection.');
    } catch (e) {
      throw ChatException('Failed to get conversation history: ${e.toString()}');
    }
  }

  // Cached conversations list
  static Future<List<Conversation>> getUserConversations(BuildContext context) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    final userId = _getUserId(context);

    // Check cache first
    if (_conversationCache.containsKey(userId)) {
      return _conversationCache[userId]!;
    }

    try {
      final response = await _httpClient
          .get(
        Uri.parse('$baseUrl/api/chat/user/$userId'),
        headers: _getHeaders(context),
      )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> conversations = jsonDecode(response.body);

        final conversationList = conversations
            .map((conv) => Conversation.fromBackendJson(conv))
            .toList();

        // Cache the result
        _conversationCache[userId] = conversationList;

        return conversationList;
      } else {
        throw ChatException('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw ChatException('Request timeout. Please check your connection.');
    } catch (e) {
      throw ChatException('Failed to get conversations: ${e.toString()}');
    }
  }

  // Optimized delete with cache invalidation
  static Future<bool> deleteConversation(
      BuildContext context,
      String conversationId,
      ) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    try {
      final response = await _httpClient
          .delete(
        Uri.parse('$baseUrl/api/chat/$conversationId'),
        headers: _getHeaders(context),
      )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        // Remove from cache
        _messageCache.remove(conversationId);
        _invalidateConversationCache();
        return true;
      }

      return false;
    } on TimeoutException {
      throw ChatException('Request timeout. Please check your connection.');
    } catch (e) {
      throw ChatException('Failed to delete conversation: ${e.toString()}');
    }
  }

  static void _invalidateConversationCache() {
    _conversationCache.clear();
  }

  // Add message to cache for immediate UI update
  static void addMessageToCache(String conversationId, ChatMessage message) {
    if (_messageCache.containsKey(conversationId)) {
      _messageCache[conversationId]!.add(message);
    }
  }

  // Update message in cache
  static void updateMessageInCache(String conversationId, ChatMessage updatedMessage) {
    if (_messageCache.containsKey(conversationId)) {
      final messages = _messageCache[conversationId]!;
      final index = messages.indexWhere((msg) => msg.id == updatedMessage.id);
      if (index != -1) {
        messages[index] = updatedMessage;
      }
    }
  }

  // Get FAQ data with caching
  static List<FaqItem>? _cachedFaqs;

  static Future<List<FaqItem>> getFaqs(BuildContext context) async {
    // Return cached FAQs if available
    if (_cachedFaqs != null) {
      return _cachedFaqs!;
    }

    try {
      final response = await _httpClient
          .get(
        Uri.parse('$baseUrl/api/faqs'),
        headers: _getHeaders(context),
      )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final faqs = data['faqs'] as List;

        _cachedFaqs = faqs.map((faq) => FaqItem.fromJson(faq)).toList();
        return _cachedFaqs!;
      } else {
        throw ChatException('HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      throw ChatException('Request timeout. Please check your connection.');
    } catch (e) {
      throw ChatException('Failed to get FAQs: ${e.toString()}');
    }
  }
}

// Optimized response model
class ChatResponse {
  final String? conversationId;
  final String reply;
  final String? message;
  final ChatDiagnosis? diagnosis;

  ChatResponse({
    this.conversationId,
    required this.reply,
    this.message,
    this.diagnosis,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      conversationId: json['conversationId'] as String?,
      reply: json['reply'] as String,
      message: json['message'] as String?,
      diagnosis: json['diagnosis'] != null
          ? ChatDiagnosis.fromJson(json['diagnosis'])
          : null,
    );
  }

  ChatMessage toAIMessage() {
    return ChatMessage(
      isUser: false,
      message: reply,
      timestamp: _getCurrentTime(),
      diagnosis: diagnosis,
      conversationId: conversationId,
      status: MessageStatus.sent,
    );
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}

// Lightweight FAQ model
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String keywords;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id'].toString(),
      question: json['question'] as String,
      answer: json['answer'] as String,
      keywords: json['keywords'] as String? ?? '',
    );
  }
}

class ChatException implements Exception {
  final String message;
  const ChatException(this.message);

  @override
  String toString() => 'ChatException: $message';
}

// Extension for better list performance
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
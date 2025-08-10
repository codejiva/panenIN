// lib/features/chatbot/services/auth_aware_chat_service.dart
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

  // Get auth provider from context
  static AuthProvider _getAuthProvider(BuildContext context) {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  // Get user ID from auth provider
  static String _getUserId(BuildContext context) {
    final authProvider = _getAuthProvider(context);
    final userData = authProvider.userData;

    // Extract user ID from userData - adjust according to your API response structure
    return userData?['id']?.toString() ??
        userData?['user_id']?.toString() ??
        userData?['userId']?.toString() ??
        userData?['_id']?.toString() ??
        'unknown_user';
  }

  // Get current user token
  static String? _getToken(BuildContext context) {
    final authProvider = _getAuthProvider(context);
    return authProvider.token;
  }

  // Get authorization headers
  static Map<String, String> _getHeaders(BuildContext context) {
    final token = _getToken(context);
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get multipart headers for file upload
  static Map<String, String> _getMultipartHeaders(BuildContext context) {
    final token = _getToken(context);
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Check if user is authenticated
  static bool _isAuthenticated(BuildContext context) {
    final authProvider = _getAuthProvider(context);
    return authProvider.isLoggedIn && authProvider.token != null;
  }

  // Start a new chat conversation
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

  // Continue existing conversation
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

  // Send text message
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

    final response = await http.post(
      Uri.parse(url),
      headers: _getHeaders(context),
      body: body,
    );

    print('Berhasil get ${response.body} ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ChatResponse.fromJson(data);
    } else {
      throw ChatException('Failed to send message: ${response.statusCode} - ${response.body}');
    }
  }

  // Send message with file
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

    final request = http.MultipartRequest('POST', Uri.parse(url));

    // Add headers
    request.headers.addAll(_getMultipartHeaders(context));

    // Add text fields
    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }
    request.fields['userId'] = userId;

    // Add file
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: file.path.split('/').last,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ChatResponse.fromJson(data);
    } else {
      throw ChatException('Failed to send file: ${response.statusCode} - ${response.body}');
    }
  }

  // Get conversation history
  static Future<List<ChatMessage>> getConversationHistory(
      BuildContext context,
      String conversationId,
      ) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/$conversationId/messages'),
        headers: _getHeaders(context),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final messages = data['messages'] as List;

          return messages.map((messageJson) {
            final role = messageJson['role'] as String;
            return ChatMessage.fromBackendMessage(
              messageJson,
              isUser: role == 'user',
            );
          }).toList();
        } else {
          throw ChatException('Backend returned error: ${data['error']}');
        }
      } else {
        throw ChatException('Failed to get conversation history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw ChatException('Failed to get conversation history: ${e.toString()}');
    }
  }

  // Get all conversations for user
  static Future<List<Conversation>> getUserConversations(BuildContext context) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    try {
      final userId = _getUserId(context);
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/conversations?userId=$userId'),
        headers: _getHeaders(context),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final conversations = data['conversations'] as List;

          return conversations.map((conv) => Conversation.fromJson(conv)).toList();
        } else {
          throw ChatException('Backend returned error: ${data['error']}');
        }
      } else {
        throw ChatException('Failed to get conversations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw ChatException('Failed to get conversations: ${e.toString()}');
    }
  }

  // Delete conversation
  static Future<bool> deleteConversation(
      BuildContext context,
      String conversationId,
      ) async {
    if (!_isAuthenticated(context)) {
      throw ChatException('User is not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat/$conversationId'),
        headers: _getHeaders(context),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw ChatException('Failed to delete conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw ChatException('Failed to delete conversation: ${e.toString()}');
    }
  }

  // Get FAQ data (if needed)
  static Future<List<FaqItem>> getFaqs(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/faqs'),
        headers: _getHeaders(context),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final faqs = data['faqs'] as List;

        return faqs.map((faq) => FaqItem.fromJson(faq)).toList();
      } else {
        throw ChatException('Failed to get FAQs: ${response.statusCode}');
      }
    } catch (e) {
      throw ChatException('Failed to get FAQs: ${e.toString()}');
    }
  }
}

// Response model for chat API
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

  // Convert to ChatMessage for UI
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

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}

// FAQ model
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String keywords;

  FaqItem({
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

// Custom exception class
class ChatException implements Exception {
  final String message;

  ChatException(this.message);

  @override
  String toString() => 'ChatException: $message';
}
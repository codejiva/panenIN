// File: lib/features/forum/services/forum_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/forum_model.dart';

class ForumService {
  static const String _baseUrl = 'https://panen-in-teal.vercel.app/api';
  static const Duration _timeout = Duration(seconds: 30);

  // Singleton pattern
  static final ForumService _instance = ForumService._internal();
  factory ForumService() => _instance;
  ForumService._internal();

  // HTTP client with default headers
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Fetches all forum posts from the API
  /// Returns a list of [ForumPost] objects
  /// Throws [Exception] if the request fails
  Future<List<ForumPost>> getForumPosts({
    String sortBy = 'created_at',
    String order = 'DESC',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/forum/posts').replace(
        queryParameters: {
          'sortBy': sortBy,
          'order': order,
        },
      );

      debugPrint('Fetching forum posts from: $uri');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData
            .map((postJson) => ForumPost.fromJson(postJson))
            .toList();
      } else {
        throw Exception('Failed to load forum posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getForumPosts: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetches a specific forum post by ID with all replies
  /// Returns a [ForumPost] object
  /// Throws [Exception] if the request fails
  Future<ForumPost> getForumPost(
      int postId, {
        String sortBy = 'created_at',
        String order = 'ASC',
        String? filter,
      }) async {
    try {
      final queryParams = <String, String>{
        'sortBy': sortBy,
        'order': order,
      };

      if (filter != null) {
        queryParams['filter'] = filter;
      }

      // Use path parameter for postId
      final uri = Uri.parse('$_baseUrl/forum/posts/').replace(
        queryParameters: queryParams,
      );

      debugPrint('Fetching forum post from: $uri');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Handle both single object and array responses
        if (jsonData is List) {
          // If backend returns array, find the post with matching ID
          final postMap = (jsonData as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (post) => post['id'] == postId,
            orElse: () => throw Exception('Post with ID $postId not found'),
          );
          return ForumPost.fromJson(postMap);
        } else if (jsonData is Map<String, dynamic>) {
          // If backend returns single object
          return ForumPost.fromJson(jsonData);
        } else {
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Forum post not found');
      } else {
        throw Exception('Failed to load forum post. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getForumPost: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Creates a new forum post
  /// Returns success status
  /// Throws [Exception] if the request fails
  Future<bool> submitForumPost({
    required int userId,
    required String title,
    required String content,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/forum/posts');
      final body = json.encode({
        'userId': userId,
        'title': title,
        'content': content,
      });

      debugPrint('Creating forum post: $uri');
      debugPrint('Request body: $body');

      final response = await http
          .post(uri, headers: _defaultHeaders, body: body)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create forum post. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in submitForumPost: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Creates a reply to a forum post
  /// Returns success status
  /// Throws [Exception] if the request fails
  Future<bool> createReply({
    required int postId,
    required String content,
    required int userId,
    int? parentReplyId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/forum/posts/$postId/reply');
      final body = json.encode({
        'content': content,
        'userId': userId,
        if (parentReplyId != null) 'parentReplyId': parentReplyId,
      });

      debugPrint('Creating reply: $uri');
      debugPrint('Request body: $body');

      final response = await http
          .post(uri, headers: _defaultHeaders, body: body)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create reply. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in createReply: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Toggles like on a post or reply
  /// Returns success status
  /// Throws [Exception] if the request fails
  Future<bool> toggleLike({
    int? postId,
    int? replyId,
    required int userId,
  }) async {
    if (postId == null && replyId == null) {
      throw Exception('Either postId or replyId must be provided');
    }

    if (postId != null && replyId != null) {
      throw Exception('Only one of postId or replyId should be provided');
    }

    try {
      late Uri uri;
      if (postId != null) {
        uri = Uri.parse('$_baseUrl/forum/posts/$postId/like');
      } else {
        uri = Uri.parse('$_baseUrl/forum/replies/$replyId/like');
      }

      final body = json.encode({
        'userId': userId,
      });

      debugPrint('Toggling like: $uri');
      debugPrint('Request body: $body');

      final response = await http
          .post(uri, headers: _defaultHeaders, body: body)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to toggle like. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in toggleLike: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Approves a reply (for advisors only)
  /// Returns success status
  /// Throws [Exception] if the request fails
  Future<bool> approveReply({
    required int replyId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/forum/replies/$replyId/approve');

      debugPrint('Approving reply: $uri');

      final response = await http
          .patch(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Reply not found');
      } else {
        throw Exception('Failed to approve reply. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in approveReply: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Fetches posts with pagination support
  /// Returns a list of [ForumPost] objects
  /// Throws [Exception] if the request fails
  Future<List<ForumPost>> getForumPostsPaginated({
    int page = 1,
    int limit = 10,
    String sortBy = 'created_at',
    String order = 'DESC',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/forum/posts').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'sortBy': sortBy,
          'order': order,
        },
      );

      debugPrint('Fetching paginated forum posts from: $uri');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if response has pagination structure
        if (responseData.containsKey('data')) {
          final List<dynamic> jsonData = responseData['data'];
          return jsonData
              .map((postJson) => ForumPost.fromJson(postJson))
              .toList();
        } else {
          // Fallback to direct array response
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData
              .map((postJson) => ForumPost.fromJson(postJson))
              .toList();
        }
      } else {
        throw Exception('Failed to load forum posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getForumPostsPaginated: $e');
      throw Exception('Network error: $e');
    }
  }
}
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
    int? userId, // Add userId to check like status
  }) async {
    try {
      final queryParams = {
        'sortBy': sortBy,
        'order': order,
      };

      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }

      final uri = Uri.parse('$_baseUrl/forum/posts').replace(
        queryParameters: queryParams,
      );

      debugPrint('Fetching forum posts from: $uri');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);

          return jsonData
              .map((postJson) {
            try {
              return ForumPost.fromJson(postJson as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing post: $e');
              return null;
            }
          })
              .where((post) => post != null)
              .cast<ForumPost>()
              .toList();
        } catch (e) {
          debugPrint('Error parsing response: $e');
          return [];
        }
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
        int? userId, // Add userId to check like status
      }) async {
    try {
      final queryParams = <String, String>{
        'sortBy': sortBy,
        'order': order,
      };

      if (filter != null) {
        queryParams['filter'] = filter;
      }

      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }

      final uri = Uri.parse('$_baseUrl/forum/posts/$postId').replace(
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
        return ForumPost.fromJson(jsonData);
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
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create forum post');
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
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create reply');
      }
    } catch (e) {
      debugPrint('Error in createReply: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Toggles like on a post or reply
  /// Returns the updated like status and count
  /// Throws [Exception] if the request fails
  Future<Map<String, dynamic>> toggleLike({
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
        final responseData = json.decode(response.body);

        // ✅ Backend hanya mengembalikan message, jadi kita return success saja
        // Frontend akan menggunakan optimistic update untuk UI
        return {
          'success': true,
          'message': responseData['message'] ?? 'Like toggled successfully',
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to toggle like');
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
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to approve reply');
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
    int? userId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'order': order,
      };

      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }

      final uri = Uri.parse('$_baseUrl/forum/posts').replace(
        queryParameters: queryParams,
      );

      debugPrint('Fetching paginated forum posts from: $uri');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);

          // Check if response has pagination structure
          if (responseData.containsKey('data')) {
            final List<dynamic> jsonData = responseData['data'];
            return jsonData
                .map((postJson) {
              try {
                return ForumPost.fromJson(postJson as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing paginated post: $e');
                return null;
              }
            })
                .where((post) => post != null)
                .cast<ForumPost>()
                .toList();
          } else {
            // Fallback to direct array response
            final List<dynamic> jsonData = json.decode(response.body);
            return jsonData
                .map((postJson) {
              try {
                return ForumPost.fromJson(postJson as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing direct post: $e');
                return null;
              }
            })
                .where((post) => post != null)
                .cast<ForumPost>()
                .toList();
          }
        } catch (e) {
          debugPrint('Error parsing paginated response: $e');
          return [];
        }
      } else {
        throw Exception('Failed to load forum posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getForumPostsPaginated: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Gets reply count for a specific post
  Future<int> getReplyCount(int postId) async {
    try {
      final uri = Uri.parse('$_baseUrl/forum/posts/$postId/replies/count');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error getting reply count: $e');
      return 0;
    }
  }

  /// Gets like count for a post or reply
  Future<Map<String, dynamic>> getLikeInfo({
    int? postId,
    int? replyId,
    int? userId,
  }) async {
    try {
      late Uri uri;
      if (postId != null) {
        uri = Uri.parse('$_baseUrl/forum/posts/$postId/likes');
      } else if (replyId != null) {
        uri = Uri.parse('$_baseUrl/forum/replies/$replyId/likes');
      } else {
        throw Exception('Either postId or replyId must be provided');
      }

      if (userId != null) {
        uri = uri.replace(queryParameters: {'userId': userId.toString()});
      }

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'count': 0, 'isLiked': false};
      }
    } catch (e) {
      debugPrint('Error getting like info: $e');
      return {'count': 0, 'isLiked': false};
    }
  }

  /// Search posts by title or content
  Future<List<ForumPost>> searchPosts({
    required String query,
    String sortBy = 'created_at',
    String order = 'DESC',
    int? userId,
  }) async {
    try {
      final queryParams = {
        'search': query,
        'sortBy': sortBy,
        'order': order,
      };

      if (userId != null) {
        queryParams['userId'] = userId.toString();
      }

      final uri = Uri.parse('$_baseUrl/forum/posts').replace(
        queryParameters: queryParams,
      );

      debugPrint('Searching posts: $uri');

      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData
              .map((postJson) {
            try {
              return ForumPost.fromJson(postJson as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing search result: $e');
              return null;
            }
          })
              .where((post) => post != null)
              .cast<ForumPost>()
              .toList();
        } catch (e) {
          debugPrint('Error parsing search response: $e');
          return [];
        }
      } else {
        throw Exception('Failed to search posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in searchPosts: $e');
      throw Exception('Network error: $e');
    }
  }
}
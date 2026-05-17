import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gospel_stream/config/app_config.dart';
import 'package:gospel_stream/models/chat_message.dart';
import 'package:gospel_stream/models/content_item.dart';

class BackendService {
  BackendService._();

  static Uri _buildUri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    return query != null ? uri.replace(queryParameters: query) : uri;
  }

  static Future<List<ContentItem>> fetchContent({int limit = 40}) async {
    final uri = _buildUri('/content', {'limit': '$limit'});
    final response =
        await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch content from backend (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Map<String, String> _buildHeaders(
      {String? token, bool jsonContent = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonContent) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<ChatMessage>> fetchMessages(String contentId,
      {int limit = 50}) async {
    final uri = _buildUri('/chat/$contentId/messages', {'limit': '$limit'});
    final response = await http.get(uri, headers: _buildHeaders());

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch chat messages from backend (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final uri = _buildUri('/auth/login');
    final response = await http.post(
      uri,
      headers: _buildHeaders(token: null, jsonContent: true),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to login (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final uri = _buildUri('/auth/register');
    final response = await http.post(
      uri,
      headers: _buildHeaders(token: null, jsonContent: true),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final uri = _buildUri('/auth/me');
    final response = await http.get(uri, headers: _buildHeaders(token: token));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch current user (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<ContentItem> createContent({
    required String title,
    required String type,
    required String thumbnailUrl,
    required String contentUrl,
    required int duration,
    String? subtitle,
    String? description,
    String? category,
    String? artist,
    String? album,
    String? genre,
    String? audioFormat,
    String? token,
  }) async {
    final uri = _buildUri('/content');
    final response = await http.post(
      uri,
      headers: _buildHeaders(token: token, jsonContent: true),
      body: jsonEncode({
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'type': type,
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'contentUrl': contentUrl,
        'duration': duration,
        'artist': artist,
        'album': album,
        'genre': genre,
        'audioFormat': audioFormat,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create content (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return ContentItem.fromJson(data);
  }

  static Future<void> likeContent(String contentId, {String? token}) async {
    final uri = _buildUri('/content/$contentId/like');
    final response = await http.post(uri, headers: _buildHeaders(token: token));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to like content (${response.statusCode})');
    }
  }

  static Future<ChatMessage> postMessage(String contentId, String message,
      {String? token}) async {
    final uri = _buildUri('/chat/$contentId/messages');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatMessage.fromJson(body['data'] as Map<String, dynamic>);
  }
}

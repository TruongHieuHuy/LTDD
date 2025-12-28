import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/config_url.dart';
import 'api_exception.dart';

/// A client to handle raw HTTP communication, token management, and error wrapping.
/// This class is intended to be provided and shared across different domain-specific services.
class ApiClient {
  // Base URL from config
  static String get baseUrl => ConfigUrl.baseUrl;

  // JWT Token storage
  String? _authToken;

  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;

  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('ApiClient: Token set.');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    debugPrint('ApiClient: Token cleared.');
  }

  /// Get headers with authentication
  Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Centralized request helper to reduce boilerplate code.
  /// Handles HTTP requests, response parsing, and error handling.
  Future<T> request<T>(
    String debugLabel, {
    required Future<http.Response> Function() httpRequest,
    required T Function(dynamic data) onSuccess,
    String? defaultErrorMessage,
  }) async {
    try {
      final response = await httpRequest();

      // Handle cases with no content but a successful status code
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return onSuccess(null);
        } else {
          throw ApiException(
            message: defaultErrorMessage ?? 'Request failed with empty response',
            statusCode: response.statusCode,
          );
        }
      }
      
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return onSuccess(data);
      } else {
        throw ApiException(
          message: data['message'] ?? data['error'] ?? defaultErrorMessage ?? 'An unknown error occurred',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('ApiClient ($debugLabel) error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error or parsing issue: ${e.toString()}');
    }
  }

  /// Upload image file using a multipart request.
  Future<String> uploadImage(String filePath) async {
    final url = Uri.parse('$baseUrl/api/upload');
    try {
      final request = http.MultipartRequest('POST', url);

      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return data['imageUrl'];
      } else {
        throw ApiException(
            message: data['message'] ?? data['error'] ?? 'Failed to upload image',
            statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error while uploading image: $e');
    }
  }
}

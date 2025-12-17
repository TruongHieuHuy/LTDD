import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../config/api_config.dart';

/// Service for interacting with Gemini AI API
class GeminiApiService {
  final Dio _dio;
  DateTime? _lastRequestTime;
  int _requestCount = 0;
  DateTime? _firstRequestTime;

  static const _minRequestInterval = Duration(
    seconds: 5,
  ); // Reduced to 5s for better UX
  static const _maxRequestsPerMinute = 8; // Increased to 8 requests/min

  GeminiApiService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: ApiConfig.connectionTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// Generate content from Gemini AI with retry logic
  ///
  /// [prompt] - The complete prompt including system instructions and user query
  /// [maxRetries] - Maximum number of retry attempts (default: 1)
  /// Returns AI-generated response text
  Future<String> generateContent(String prompt, {int maxRetries = 1}) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount <= maxRetries) {
      try {
        // Rate limiting: wait if last request was too recent
        await _enforceRateLimit();

        final response = await _dio.post(
          ApiConfig.geminiApiUrl,
          data: {
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 1024,
            },
            'safetySettings': [
              {
                'category': 'HARM_CATEGORY_HARASSMENT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
              {
                'category': 'HARM_CATEGORY_HATE_SPEECH',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
              },
            ],
          },
        );

        _lastRequestTime = DateTime.now();

        if (response.statusCode == 200) {
          final data = response.data;

          // Extract text from response
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            final candidate = data['candidates'][0];
            if (candidate['content'] != null &&
                candidate['content']['parts'] != null &&
                candidate['content']['parts'].isNotEmpty) {
              final text = candidate['content']['parts'][0]['text'] as String;
              return _processResponse(text);
            }
          }

          throw Exception('Invalid response format from Gemini API');
        } else {
          throw Exception('API Error: ${response.statusCode}');
        }
      } on DioException catch (e) {
        lastException = e;

        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception('Không thể kết nối. Vui lòng kiểm tra internet.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Phản hồi quá lâu. Vui lòng thử lại.');
        } else if (e.response != null) {
          final statusCode = e.response!.statusCode;
          if (statusCode == 429) {
            // Rate limit exceeded - wait longer before retry
            if (retryCount < maxRetries) {
              retryCount++;
              final waitTime = Duration(seconds: 10); // Wait 10s before retry
              debugPrint(
                'Rate limit hit, waiting ${waitTime.inSeconds}s before retry $retryCount/$maxRetries',
              );
              await Future.delayed(waitTime);
              continue; // Retry
            } else {
              // All retries exhausted - return helpful fallback
              debugPrint('⚠️ API quota exceeded, using fallback response');
              return '''🤖 **Tôi là Kajima AI - Game Consultant của bạn!**

💬 Tôi có thể giúp bạn:
• **Giải thích luật chơi** Đoán Số và Bò & Bê
• **Phân tích thống kê** và điểm số của bạn
• **Đưa ra tips** để cải thiện kỹ năng
• **Hướng dẫn** unlock achievements

🎮 **Hãy hỏi tôi về:**
- "Cách chơi Đoán Số?"
- "Thống kê của tôi thế nào?"
- "Tips để chơi Bò & Bê tốt hơn?"
- "Còn huy hiệu nào chưa unlock?"

⚡ **Hoặc dùng Quick Actions** bên trên để được trả lời ngay lập tức!''';
            }
          } else if (statusCode == 400) {
            throw Exception(
              'Yêu cầu không hợp lệ. Vui lòng thử cách hỏi khác.',
            );
          } else if (statusCode == 403) {
            throw Exception('API key không hợp lệ hoặc đã hết hạn.');
          }
          throw Exception('Lỗi API: ${e.response!.statusCode}');
        } else {
          throw Exception('Lỗi mạng: ${e.message}');
        }
      } catch (e) {
        lastException = Exception(e.toString());
        if (retryCount < maxRetries && !e.toString().contains('không hợp lệ')) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount));
          continue; // Retry for generic errors
        }
        throw Exception('Không thể tạo phản hồi: $e');
      }
    }

    // Should not reach here, but just in case
    if (lastException != null) {
      throw lastException;
    }
    throw Exception('Đã thử ${maxRetries + 1} lần nhưng không thành công.');
  }

  /// Enforce rate limiting between requests
  Future<void> _enforceRateLimit() async {
    // Check requests per minute limit
    if (_firstRequestTime != null) {
      final timeSinceFirst = DateTime.now().difference(_firstRequestTime!);
      if (timeSinceFirst < Duration(minutes: 1)) {
        if (_requestCount >= _maxRequestsPerMinute) {
          final waitTime = Duration(minutes: 1) - timeSinceFirst;
          debugPrint(
            '⏳ Rate limit: ${_requestCount} requests in last minute. Waiting ${waitTime.inSeconds}s',
          );
          await Future.delayed(waitTime);
          _requestCount = 0;
          _firstRequestTime = DateTime.now();
        }
      } else {
        // Reset counter after 1 minute
        _requestCount = 0;
        _firstRequestTime = DateTime.now();
      }
    } else {
      _firstRequestTime = DateTime.now();
    }

    // Check minimum interval between requests
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        debugPrint('⏳ Waiting ${waitTime.inSeconds}s before next API call');
        await Future.delayed(waitTime);
      }
    }

    _requestCount++;
  }

  /// Process AI response text
  /// - Remove excessive whitespace
  /// - Format markdown
  /// - Handle special characters
  String _processResponse(String text) {
    // Trim whitespace
    String processed = text.trim();

    // Remove multiple consecutive newlines (keep max 2)
    processed = processed.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Ensure proper spacing after punctuation
    processed = processed.replaceAll(RegExp(r'([.!?])([A-Z])'), r'$1 $2');

    return processed;
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      await generateContent('Hello');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get estimated tokens for a text (rough approximation)
  int estimateTokens(String text) {
    // Rough estimate: 1 token ≈ 4 characters for English
    // Vietnamese might be slightly different
    return (text.length / 4).ceil();
  }

  /// Check if prompt exceeds token limit
  bool exceedsTokenLimit(String prompt) {
    return estimateTokens(prompt) > ApiConfig.maxInputTokens;
  }
}

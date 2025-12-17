/// API Configuration for Chatbot AI
/// Contains API keys and endpoints
class ApiConfig {
  // Gemini API Configuration
  static const String geminiApiKey = 'AIzaSyDvX5M3sGXPn3-lO9xFil5vps_mXACFXUA';

  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // API Limits (Free tier)
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerDay = 1500;
  static const int maxInputTokens = 30720;
  static const int maxOutputTokens = 2048;

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Get full API URL with key
  static String get geminiApiUrl => '$geminiEndpoint?key=$geminiApiKey';
}

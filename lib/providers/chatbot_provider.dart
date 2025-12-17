import 'package:flutter/foundation.dart';
import '../models/chatbot_message_model.dart';
import '../utils/database_service.dart';
import '../utils/gemini_api_service.dart';
import '../utils/game_context_service.dart';
import '../utils/fallback_response_service.dart';
import '../utils/intelligent_fallback_service.dart';
import '../providers/game_provider.dart';

/// Provider for chatbot functionality with game integration
class ChatbotProvider extends ChangeNotifier {
  final GeminiApiService _geminiApi = GeminiApiService();

  List<ChatbotMessage> _messages = [];
  bool _isTyping = false;
  String? _error;
  GameProvider? _gameProvider;
  DateTime? _lastMessageTime;
  DateTime? _lastApiCallTime;
  static const _minMessageInterval = Duration(
    seconds: 2,
  ); // User rate limit (reduced to 2s)
  static const _minApiInterval = Duration(
    seconds: 5,
  ); // API rate limit (optimized to 5s)

  // Getters
  List<ChatbotMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;
  int get messageCount => _messages.length;

  /// Initialize provider and load chat history
  ChatbotProvider() {
    _loadMessages();
  }

  /// Set game provider for context injection
  void setGameProvider(GameProvider gameProvider) {
    _gameProvider = gameProvider;
  }

  /// Load messages from Hive
  void _loadMessages() {
    _messages = DatabaseService.getRecentChatbotMessages(limit: 100);
    notifyListeners();
  }

  /// Send text message from user
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Check if user is sending messages too fast
    if (_lastMessageTime != null) {
      final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);
      if (timeSinceLastMessage < _minMessageInterval) {
        // Show warning message
        final warningMsg = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'BOT',
          message:
              '⏱️ Vui lòng đợi ${_minMessageInterval.inSeconds} giây giữa các tin nhắn để tránh lỗi rate limit.',
          timestamp: DateTime.now(),
          messageType: 'text',
        );
        _messages.add(warningMsg);
        notifyListeners();
        return;
      }
    }

    _error = null;
    _lastMessageTime = DateTime.now();

    // Add user message
    final userMsg = ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'USER',
      message: text,
      timestamp: DateTime.now(),
      messageType: 'text',
    );

    _messages.add(userMsg);
    await DatabaseService.saveChatbotMessage(userMsg);
    notifyListeners();

    // Get bot response
    await _getBotResponse(text);
  }

  /// Add bot message directly (for suggestion responses)
  Future<void> addBotMessage(String message) async {
    final botMsg = ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'BOT',
      message: message,
      timestamp: DateTime.now(),
      messageType: 'text',
    );

    _messages.add(botMsg);
    await DatabaseService.saveChatbotMessage(botMsg);
    notifyListeners();
  }

  /// Send predefined quick action message
  Future<void> sendQuickAction(String action) async {
    // ALWAYS use fallback for quick actions - no API calls!
    final fallbackResponse = FallbackResponseService.getFallbackResponse(
      action,
    );

    if (fallbackResponse != null) {
      // Use offline fallback - instant response!
      final botMsg = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'BOT',
        message: fallbackResponse,
        timestamp: DateTime.now(),
        messageType: 'text',
      );

      _messages.add(botMsg);
      await DatabaseService.saveChatbotMessage(botMsg);
      notifyListeners();
      return; // Don't call API
    }

    // If no fallback, use API (for custom actions)
    String message;

    switch (action) {
      case 'rules_guess':
        message = 'Giải thích chi tiết cách chơi game Đoán Số';
        break;
      case 'rules_bulls':
        message = 'Giải thích chi tiết cách chơi game Bò & Bê';
        break;
      case 'my_stats':
        message = 'Xem thống kê chi tiết của tôi';
        break;
      case 'tips':
        message = 'Cho tôi tips để chơi tốt hơn';
        break;
      case 'achievements':
        message = 'Còn huy hiệu nào chưa unlock?';
        break;
      case 'leaderboard':
        message = 'Tôi xếp hạng mấy?';
        break;
      default:
        message = action;
    }

    await sendTextMessage(message);
  }

  /// Get bot response with game context
  Future<void> _getBotResponse(String userMessage) async {
    _isTyping = true;
    _error = null;
    notifyListeners();

    // Check if we need to wait before API call
    if (_lastApiCallTime != null) {
      final timeSinceLastCall = DateTime.now().difference(_lastApiCallTime!);
      if (timeSinceLastCall < _minApiInterval) {
        final waitTime = _minApiInterval - timeSinceLastCall;
        debugPrint(
          '⏰ Waiting ${waitTime.inSeconds}s before API call to avoid rate limit',
        );

        // ALWAYS use smart fallback if available - faster UX
        final smartFallback = _getSmartFallback(userMessage);
        if (smartFallback != null) {
          final botMsg = ChatbotMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'BOT',
            message: smartFallback,
            timestamp: DateTime.now(),
            messageType: 'text',
          );
          _messages.add(botMsg);
          await DatabaseService.saveChatbotMessage(botMsg);
          _isTyping = false;
          notifyListeners();
          return;
        }

        // Wait remaining time
        await Future.delayed(waitTime);
      }
    }

    _lastApiCallTime = DateTime.now();

    try {
      // Build prompt with game context if available
      String prompt;
      if (_gameProvider != null) {
        prompt = GameContextService.buildCompletePrompt(
          userMessage,
          _gameProvider!,
        );
      } else {
        // Fallback without game context
        prompt =
            '''${GameContextService.buildSystemPrompt()}

[USER QUESTION]
$userMessage

[YOUR RESPONSE]
''';
      }

      // Check token limit
      if (_geminiApi.exceedsTokenLimit(prompt)) {
        throw Exception('Câu hỏi quá dài. Vui lòng rút gọn lại.');
      }

      // Call Gemini API with retry logic (reduced to 1 retry)
      final response = await _geminiApi.generateContent(prompt, maxRetries: 1);

      // If response is empty or generic (API failed), use intelligent fallback
      if (response.isEmpty || response.startsWith('🤖 **Tôi là Kajima AI')) {
        throw Exception('API_FALLBACK');
      }

      // Add bot message (even if it's a rate limit message, it's still valid response)
      final botMsg = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'BOT',
        message: response,
        timestamp: DateTime.now(),
        messageType: 'text',
      );

      _messages.add(botMsg);
      await DatabaseService.saveChatbotMessage(botMsg);
    } catch (e) {
      _error = e.toString();

      // Always use intelligent fallback for better UX
      final intelligentResponse =
          IntelligentFallbackService.getIntelligentResponse(userMessage);

      final botMsg = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'BOT',
        message: intelligentResponse,
        timestamp: DateTime.now(),
        messageType: 'text',
      );

      _messages.add(botMsg);
      await DatabaseService.saveChatbotMessage(botMsg);

      debugPrint('Chatbot using intelligent fallback for: $userMessage');
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Get game rules for specific game
  Future<void> getGameRules(String gameType) async {
    final rules = GameContextService.getGameRules(gameType);

    final botMsg = ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'BOT',
      message: rules,
      timestamp: DateTime.now(),
      messageType: 'game_rule',
    );

    _messages.add(botMsg);
    await DatabaseService.saveChatbotMessage(botMsg);
    notifyListeners();
  }

  /// Get tips for specific game
  Future<void> getGameTips(String gameType, [String? difficulty]) async {
    final tips = GameContextService.getGameTips(gameType, difficulty);

    final tipsText = StringBuffer();
    tipsText.writeln('💡 TIPS CHO ${gameType.toUpperCase()}');
    if (difficulty != null) {
      tipsText.writeln('Độ khó: $difficulty');
    }
    tipsText.writeln();

    for (int i = 0; i < tips.length; i++) {
      tipsText.writeln('${i + 1}. ${tips[i]}');
    }

    final botMsg = ChatbotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'BOT',
      message: tipsText.toString(),
      timestamp: DateTime.now(),
      messageType: 'tip',
    );

    _messages.add(botMsg);
    await DatabaseService.saveChatbotMessage(botMsg);
    notifyListeners();
  }

  /// Clear all chat history
  Future<void> clearHistory() async {
    await DatabaseService.clearChatbotMessages();
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  /// Delete specific message
  Future<void> deleteMessage(int index) async {
    if (index >= 0 && index < _messages.length) {
      final message = _messages[index];
      await message.delete();
      _messages.removeAt(index);
      notifyListeners();
    }
  }

  /// Reload messages from database
  void reloadMessages() {
    _loadMessages();
  }

  /// Test API connection
  Future<bool> testApiConnection() async {
    try {
      return await _geminiApi.testConnection();
    } catch (e) {
      return false;
    }
  }

  /// Get smart fallback based on user message
  String? _getSmartFallback(String userMessage) {
    final msg = userMessage.toLowerCase();

    // Game rules - exact matches only
    if ((msg.contains('đoán số') || msg.contains('doan so')) &&
        (msg.contains('cách chơi') ||
            msg.contains('luật') ||
            msg.contains('rule'))) {
      return FallbackResponseService.getFallbackResponse('rules_guess');
    }

    if ((msg.contains('bò') ||
            msg.contains('bê') ||
            msg.contains('mastermind')) &&
        (msg.contains('cách chơi') ||
            msg.contains('luật') ||
            msg.contains('rule'))) {
      return FallbackResponseService.getFallbackResponse('rules_cowsbulls');
    }

    // Stats - exact matches only
    if ((msg.contains('thống kê') ||
            msg.contains('thong ke') ||
            msg.contains('stats')) &&
        msg.length < 30) {
      // Short queries only
      return FallbackResponseService.getFallbackResponse('stats');
    }

    // Tips - exact matches only
    if ((msg.contains('tips') ||
            msg.contains('mẹo') ||
            msg.contains('chiến thuật')) &&
        msg.length < 30) {
      // Short queries only
      return FallbackResponseService.getFallbackResponse('tips');
    }

    // NO generic fallback - let API handle everything else
    return null;
  }

  /// Get welcome message
  ChatbotMessage getWelcomeMessage() {
    return ChatbotMessage(
      id: 'welcome',
      senderId: 'BOT',
      message: '''
👋 Xin chào! Tôi là **Kajima AI** - trợ lý game của bạn!

🎮 Tôi có thể giúp bạn:
• Giải thích luật chơi Đoán Số & Bò Bê
• Đưa ra tips & tricks để chơi tốt hơn
• Phân tích thống kê và thành tích của bạn
• Hướng dẫn unlock achievements
• Trả lời mọi câu hỏi về games

💬 Hãy hỏi tôi bất cứ điều gì! Hoặc dùng các nút nhanh bên dưới.
''',
      timestamp: DateTime.now(),
      messageType: 'welcome',
    );
  }

  @override
  void dispose() {
    // Cleanup if needed
    super.dispose();
  }
}

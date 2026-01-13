/// Modular Chat Suggestions Service
/// 
/// Refactored from monolithic 2238-line file into modular architecture
/// Each category is in a separate file for better maintainability
export 'chat_suggestions/base_model.dart';
export 'chat_suggestions/classic_games_suggestions.dart';
export 'chat_suggestions/new_games_suggestions.dart';
export 'chat_suggestions/challenge_suggestions.dart';
export 'chat_suggestions/social_suggestions.dart';

import 'chat_suggestions/base_model.dart';
import 'chat_suggestions/classic_games_suggestions.dart';
import 'chat_suggestions/new_games_suggestions.dart';
import 'chat_suggestions/challenge_suggestions.dart';
import 'chat_suggestions/social_suggestions.dart';

/// Service quản lý suggestions và menu hierarchy
class ChatSuggestionsService {
  /// Get main category suggestions
  static List<ChatSuggestion> getMainSuggestions() {
    return [
      // Features category (will be created separately)
      ChatSuggestion(
        id: 'features',
        title: 'Chức năng hệ thống',
        icon: '🎯',
        description: 'Khám phá tất cả tính năng',
        subItems: [], // TODO: Add feature suggestions
      ),
      
      // Games category (Combined classic + new)
      ChatSuggestion(
        id: 'games',
        title: 'Hướng dẫn Game',
        icon: '🎮',
        description: 'Luật chơi & tips',
        subItems: _getAllGameSuggestions(),
      ),
      
      // Challenge/PK category (NEW)
      ChallengeSuggestions.getMainCategory(),
      
      // Social category (NEW)
      SocialSuggestions.getMainCategory(),
      
      // Stats category
      ChatSuggestion(
        id: 'stats',
        title: 'Thống kê & Thành tích',
        icon: '📊',
        description: 'Xem progress của bạn',
        subItems: [], // TODO: Add stats suggestions
      ),
      
      // Help category
      ChatSuggestion(
        id: 'help',
        title: 'Trợ giúp',
        icon: '❓',
        description: 'FAQ & Hướng dẫn',
        subItems: [], // TODO: Add help suggestions
      ),
      
      // About category
      ChatSuggestion(
        id: 'about',
        title: 'Về Project',
        icon: '📱',
        description: 'Thông tin chi tiết',
        subItems: [], // TODO: Add about suggestions
      ),
    ];
  }

  /// Combine all games (classic + new)
  static List<ChatSuggestion> _getAllGameSuggestions() {
    return [
      ...ClassicGamesSuggestions.getAll(),
      ...NewGamesSuggestions.getAll(),
    ];
  }
}

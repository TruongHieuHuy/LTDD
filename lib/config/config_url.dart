import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigUrl {
  /// Returns the base URL for the API.
  /// Priority: .env → emulator detection → fallback
  static String get baseUrl {
    // PRIORITY 1: Check .env first (works for both emulator and real device)
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty && envUrl != 'http://YOUR_PC_IP:3000') {
      debugPrint('🌐 ConfigUrl: Using BASE_URL from .env: $envUrl');
      return envUrl;
    }

    // PRIORITY 2: Android emulator fallback
    if (!kIsWeb && Platform.isAndroid) {
      try {
        // More reliable emulator detection: check if hostname contains 'generic' or brand is 'google'
        final brand = Platform.environment['ro.product.brand']?.toLowerCase() ?? '';
        final model = Platform.environment['ro.product.model']?.toLowerCase() ?? '';
        final device = Platform.environment['ro.product.device']?.toLowerCase() ?? '';
        
        final isEmulator = brand.contains('generic') || 
                           brand == 'google' && model.contains('sdk') ||
                           device.contains('emulator') ||
                           model.contains('emulator') ||
                           device.contains('generic');
        
        if (isEmulator) {
          debugPrint('🌐 ConfigUrl: Detected Android Emulator (no .env), using 10.0.2.2:3000');
          return "http://10.0.2.2:3000";
        }
      } catch (e) {
        debugPrint('⚠️ ConfigUrl: Emulator detection failed: $e');
      }
    }

    // PRIORITY 3: Fallback with clear error message
    debugPrint('⚠️ ConfigUrl: BASE_URL not configured in .env!');
    debugPrint('📝 For real device, edit .env: BASE_URL=http://YOUR_PC_IP:3000');
    debugPrint('📝 For emulator, leave .env empty or set: BASE_URL=http://10.0.2.2:3000');
    
    // Last resort: assume emulator if no config found
    debugPrint('🌐 ConfigUrl: Falling back to emulator address 10.0.2.2:3000');
    return "http://10.0.2.2:3000";
  }

  // API endpoint shortcuts
  static String get apiAuth => "$baseUrl/api/auth";
  static String get apiGames => "$baseUrl/api/games";
  static String get apiFriends => "$baseUrl/api/friends";
  static String get apiPosts => "$baseUrl/api/posts";
  static String get apiLeaderboard => "$baseUrl/api/leaderboard";
  static String get apiAchievements => "$baseUrl/api/achievements";
}


import 'package:flutter/services.dart';

class GameAudioService {
  static const MethodChannel _channel = MethodChannel('smart_student_tools');

  // Sound names
  static const String bonk = 'bonk';
  static const String bruh = 'bruh';
  static const String victory = 'victory';
  static const String sadTrombone = 'sad_trombone';
  static const String error = 'error';
  static const String click = 'click';
  static const String troll = 'troll';

  /// Play a game sound effect
  static Future<int?> playSound(String soundName, {double volume = 1.0}) async {
    try {
      final streamId = await _channel.invokeMethod<int>('playGameSound', {
        'soundName': soundName,
        'volume': volume,
      });
      return streamId;
    } catch (e) {
      print('Error playing sound $soundName: $e');
      return null;
    }
  }

  /// Stop a specific sound stream
  static Future<void> stopSound(int streamId) async {
    try {
      await _channel.invokeMethod('stopGameSound', {'streamId': streamId});
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  /// Play bonk sound (wrong answer)
  static Future<int?> playBonk({double volume = 1.0}) =>
      playSound(bonk, volume: volume);

  /// Play bruh sound (epic fail)
  static Future<int?> playBruh({double volume = 1.0}) =>
      playSound(bruh, volume: volume);

  /// Play victory fanfare (win)
  static Future<int?> playVictory({double volume = 1.0}) async {
    try {
      return await playSound(victory, volume: volume);
    } catch (e) {
      print('Victory sound not found, skipping: $e');
      return null;
    }
  }

  /// Play sad trombone (lose)
  static Future<int?> playSadTrombone({double volume = 1.0}) =>
      playSound(sadTrombone, volume: volume);

  /// Play error buzz (invalid input)
  static Future<int?> playError({double volume = 1.0}) =>
      playSound(error, volume: volume);

  /// Play click sound (button press)
  static Future<int?> playClick({double volume = 0.5}) =>
      playSound(click, volume: volume);

  /// Play troll sound (meme moment)
  static Future<int?> playTroll({double volume = 1.0}) =>
      playSound(troll, volume: volume);
}

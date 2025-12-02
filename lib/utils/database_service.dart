import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm_model.dart';
import '../models/translation_history_model.dart';
import '../models/app_settings_model.dart';

class DatabaseService {
  static const String alarmsBoxName = 'alarms';
  static const String translationsBoxName = 'translations';
  static const String settingsBoxName = 'settings';
  static const String settingsKey = 'app_settings';

  // Boxes
  static Box<AlarmModel>? _alarmsBox;
  static Box<TranslationHistoryModel>? _translationsBox;
  static Box<AppSettingsModel>? _settingsBox;

  // Getters
  static Box<AlarmModel> get alarmsBox => _alarmsBox!;
  static Box<TranslationHistoryModel> get translationsBox => _translationsBox!;
  static Box<AppSettingsModel> get settingsBox => _settingsBox!;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AlarmModelAdapter());
    Hive.registerAdapter(TranslationHistoryModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());

    // Open boxes
    _alarmsBox = await Hive.openBox<AlarmModel>(alarmsBoxName);
    _translationsBox =
        await Hive.openBox<TranslationHistoryModel>(translationsBoxName);
    _settingsBox = await Hive.openBox<AppSettingsModel>(settingsBoxName);

    // Initialize settings if not exists
    if (_settingsBox!.isEmpty) {
      await _settingsBox!.put(settingsKey, AppSettingsModel());
    }
  }

  /// Close all boxes
  static Future<void> close() async {
    await _alarmsBox?.close();
    await _translationsBox?.close();
    await _settingsBox?.close();
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAll() async {
    await _alarmsBox?.clear();
    await _translationsBox?.clear();
    await _settingsBox?.clear();
    // Reinitialize settings
    await _settingsBox?.put(settingsKey, AppSettingsModel());
  }

  // ============ ALARM OPERATIONS ============

  static Future<void> saveAlarm(AlarmModel alarm) async {
    await _alarmsBox!.put(alarm.id, alarm);
  }

  static List<AlarmModel> getAllAlarms() {
    return _alarmsBox!.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  static AlarmModel? getAlarm(String id) {
    return _alarmsBox!.get(id);
  }

  static Future<void> deleteAlarm(String id) async {
    await _alarmsBox!.delete(id);
  }

  static Future<void> updateAlarm(AlarmModel alarm) async {
    await _alarmsBox!.put(alarm.id, alarm);
  }

  static List<AlarmModel> getEnabledAlarms() {
    return _alarmsBox!.values.where((alarm) => alarm.isEnabled).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ============ TRANSLATION HISTORY OPERATIONS ============

  static Future<void> saveTranslation(
      TranslationHistoryModel translation) async {
    await _translationsBox!.put(translation.id, translation);
  }

  static List<TranslationHistoryModel> getAllTranslations({int? limit}) {
    final list = _translationsBox!.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return limit != null ? list.take(limit).toList() : list;
  }

  static Future<void> deleteTranslation(String id) async {
    await _translationsBox!.delete(id);
  }

  static Future<void> clearTranslationHistory() async {
    await _translationsBox!.clear();
  }

  static List<TranslationHistoryModel> searchTranslations(String query) {
    return _translationsBox!.values
        .where((trans) =>
            trans.sourceText.toLowerCase().contains(query.toLowerCase()) ||
            trans.translatedText.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // ============ SETTINGS OPERATIONS ============

  static AppSettingsModel getSettings() {
    return _settingsBox!.get(settingsKey) ?? AppSettingsModel();
  }

  static Future<void> updateSettings(AppSettingsModel settings) async {
    await _settingsBox!.put(settingsKey, settings);
  }

  static Future<void> updateDarkMode(bool isDarkMode) async {
    final settings = getSettings();
    settings.isDarkMode = isDarkMode;
    await updateSettings(settings);
  }

  static Future<void> updateNotifications(bool enabled) async {
    final settings = getSettings();
    settings.notificationsEnabled = enabled;
    await updateSettings(settings);
  }

  static Future<void> updateBiometric(bool enabled) async {
    final settings = getSettings();
    settings.biometricEnabled = enabled;
    await updateSettings(settings);
  }

  static Future<void> updateLanguage(String languageCode) async {
    final settings = getSettings();
    settings.selectedLanguage = languageCode;
    await updateSettings(settings);
  }
}

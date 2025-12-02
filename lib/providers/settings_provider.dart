import 'package:flutter/material.dart';
import '../models/app_settings_model.dart';
import '../utils/database_service.dart';

class SettingsProvider with ChangeNotifier {
  AppSettingsModel _settings = AppSettingsModel();

  AppSettingsModel get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get biometricEnabled => _settings.biometricEnabled;
  String get selectedLanguage => _settings.selectedLanguage;
  double get alarmVolume => _settings.alarmVolume;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _settings = DatabaseService.getSettings();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings.isDarkMode = !_settings.isDarkMode;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateTheme(String theme) async {
    _settings.isDarkMode = theme == 'dark';
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _settings.notificationsEnabled = !_settings.notificationsEnabled;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateNotifications(bool enabled) async {
    _settings.notificationsEnabled = enabled;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleBiometric() async {
    _settings.biometricEnabled = !_settings.biometricEnabled;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _settings.selectedLanguage = languageCode;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLanguage(String languageCode) async {
    _settings.selectedLanguage = languageCode;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateVolume(double volume) async {
    _settings.alarmVolume = volume;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettingsModel newSettings) async {
    _settings = newSettings;
    await DatabaseService.updateSettings(_settings);
    notifyListeners();
  }
}

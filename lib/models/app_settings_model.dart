import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 2)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool notificationsEnabled;

  @HiveField(2)
  bool biometricEnabled;

  @HiveField(3)
  String selectedLanguage;

  @HiveField(4)
  String appVersion;

  AppSettingsModel({
    this.isDarkMode = true,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.selectedLanguage = 'vi',
    this.appVersion = '1.0.0',
  });

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'notificationsEnabled': notificationsEnabled,
    'biometricEnabled': biometricEnabled,
    'selectedLanguage': selectedLanguage,
    'appVersion': appVersion,
  };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      AppSettingsModel(
        isDarkMode: json['isDarkMode'] ?? true,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        biometricEnabled: json['biometricEnabled'] ?? false,
        selectedLanguage: json['selectedLanguage'] ?? 'vi',
        appVersion: json['appVersion'] ?? '1.0.0',
      );
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const String _boxName = 'themeBox';
  static const String _themeModeKey = 'themeMode';
  static const String _primaryColorKey = 'primaryColor';

  late Box _box;
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // System mode - check platform brightness
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Initialize Hive box and load saved theme
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    await loadTheme();
  }

  /// Load theme from Hive storage
  Future<void> loadTheme() async {
    try {
      // Load theme mode
      final savedMode = _box.get(_themeModeKey, defaultValue: 'system');
      _themeMode = _parseThemeMode(savedMode);

      // Load primary color
      final savedColor = _box.get(_primaryColorKey, defaultValue: Colors.blue.value);
      _primaryColor = Color(savedColor);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Save theme to Hive storage
  Future<void> saveTheme() async {
    try {
      await _box.put(_themeModeKey, _themeMode.toString().split('.').last);
      await _box.put(_primaryColorKey, _primaryColor.value);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Toggle between light, dark, and system theme modes
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    await saveTheme();
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await saveTheme();
      notifyListeners();
    }
  }

  /// Set primary color
  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor != color) {
      _primaryColor = color;
      await saveTheme();
      notifyListeners();
    }
  }

  /// Get light theme data
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  /// Get dark theme data
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Hệ Thống';
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _box.close();
    super.dispose();
  }
}

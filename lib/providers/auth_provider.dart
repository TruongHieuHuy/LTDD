import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/auth_model.dart';

class AuthProvider with ChangeNotifier {
  static const String _boxName = 'authBox';
  static const String _authKey = 'currentAuth';

  late Box _box;
  AuthModel? _currentAuth;

  AuthModel? get currentAuth => _currentAuth;
  bool get isLoggedIn => _currentAuth?.isLoggedIn ?? false;
  String? get userEmail => _currentAuth?.email;

  /// Initialize Hive box and load auth state
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    await _loadAuth();
  }

  /// Load authentication state from Hive
  Future<void> _loadAuth() async {
    try {
      final savedAuth = _box.get(_authKey) as AuthModel?;
      if (savedAuth != null && savedAuth.isSessionValid) {
        _currentAuth = savedAuth;
      } else {
        _currentAuth = null;
        await _box.delete(_authKey); // Clear expired session
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading auth: $e');
      _currentAuth = null;
    }
  }

  /// Save authentication state to Hive
  Future<void> _saveAuth() async {
    try {
      if (_currentAuth != null) {
        await _box.put(_authKey, _currentAuth);
      } else {
        await _box.delete(_authKey);
      }
    } catch (e) {
      debugPrint('Error saving auth: $e');
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Login with email (simplified - no password for now)
  Future<bool> login({
    required String email,
    bool rememberMe = false,
  }) async {
    try {
      // Validate email
      if (!isValidEmail(email)) {
        return false;
      }

      // Create new auth session
      final token = AuthModel.generateToken(email);
      final expiry = AuthModel.calculateExpiry(rememberMe: rememberMe);

      _currentAuth = AuthModel(
        email: email,
        sessionToken: token,
        lastLoginTime: DateTime.now(),
        rememberMe: rememberMe,
        sessionExpiry: expiry,
      );

      await _saveAuth();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      _currentAuth = null;
      await _box.delete(_authKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  /// Check if session is still valid
  Future<bool> checkSession() async {
    if (_currentAuth == null) {
      return false;
    }

    if (_currentAuth!.isSessionValid) {
      return true;
    } else {
      // Session expired, auto-logout
      await logout();
      return false;
    }
  }

  /// Extend session if remember me is enabled
  Future<void> extendSession() async {
    if (_currentAuth != null && _currentAuth!.rememberMe) {
      _currentAuth!.sessionExpiry = AuthModel.calculateExpiry(rememberMe: true);
      await _saveAuth();
      notifyListeners();
    }
  }

  /// Update remember me preference
  Future<void> updateRememberMe(bool rememberMe) async {
    if (_currentAuth != null) {
      _currentAuth!.rememberMe = rememberMe;
      _currentAuth!.sessionExpiry = AuthModel.calculateExpiry(rememberMe: rememberMe);
      await _saveAuth();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _box.close();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/auth_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  static const String _boxName = 'authBox';
  static const String _authKey = 'currentAuth';
  static const String _savedEmailKey = 'savedEmail';
  static const String _userProfileKey = 'userProfile';

  late Box _box;
  AuthModel? _currentAuth;
  String? _savedEmail;
  UserProfile? _userProfile;
  final ApiService _apiService = ApiService();

  AuthModel? get currentAuth => _currentAuth;
  bool get isLoggedIn => _currentAuth?.isLoggedIn ?? false;
  String? get userEmail => _currentAuth?.email;
  String? get savedEmail => _savedEmail;
  UserProfile? get userProfile => _userProfile;
  String? get username => _userProfile?.username;
  int get totalScore => _userProfile?.totalScore ?? 0;
  int get totalGamesPlayed => _userProfile?.totalGamesPlayed ?? 0;
  String? get token => _currentAuth?.sessionToken;
  int? get userId => _userProfile?.id;

  /// Initialize Hive box and load auth state
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    await _loadAuth();
    _savedEmail = _box.get(_savedEmailKey) as String?;

    // Load user profile from cache
    final profileJson = _box.get(_userProfileKey) as Map?;
    if (profileJson != null) {
      try {
        _userProfile = UserProfile.fromJson(
          Map<String, dynamic>.from(profileJson),
        );
      } catch (e) {
        debugPrint('Error loading user profile: $e');
      }
    }
  }

  /// Load authentication state from Hive
  Future<void> _loadAuth() async {
    try {
      final savedAuth = _box.get(_authKey) as AuthModel?;
      if (savedAuth != null && savedAuth.isSessionValid) {
        _currentAuth = savedAuth;
        // Restore token to API service
        _apiService.setAuthToken(savedAuth.sessionToken);

        // Try to refresh user profile from server
        await _refreshUserProfile();
      } else {
        _currentAuth = null;
        await _box.delete(_authKey); // Clear expired session
        _apiService.clearAuthToken();
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

  /// Save user profile to cache
  Future<void> _saveUserProfile() async {
    try {
      if (_userProfile != null) {
        await _box.put(_userProfileKey, _userProfile!.toJson());
      } else {
        await _box.delete(_userProfileKey);
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  /// Refresh user profile from server
  Future<void> _refreshUserProfile() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response.success && response.data != null) {
        _userProfile = response.data;
        await _saveUserProfile();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Login with Backend API
  Future<LoginResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final trimmedEmail = email.toLowerCase().trim();

      // Validate email format
      if (!isValidEmail(trimmedEmail)) {
        return LoginResult(success: false, message: 'Invalid email format');
      }

      // Call Backend API
      final response = await _apiService.login(
        email: trimmedEmail,
        password: password,
      );

      if (response.success && response.data != null) {
        final authData = response.data!;

        // Create auth session with real JWT token
        final expiry = AuthModel.calculateExpiry(rememberMe: rememberMe);

        _currentAuth = AuthModel(
          email: trimmedEmail,
          sessionToken: authData.token,
          lastLoginTime: DateTime.now(),
          rememberMe: rememberMe,
          sessionExpiry: expiry,
        );

        // Save user profile
        _userProfile = authData.user;
        await _saveUserProfile();

        // Save email if remember me
        if (rememberMe) {
          _savedEmail = trimmedEmail;
          await _box.put(_savedEmailKey, trimmedEmail);
        } else {
          _savedEmail = null;
          await _box.delete(_savedEmailKey);
        }

        await _saveAuth();
        notifyListeners();

        return LoginResult(success: true, message: 'Login successful');
      } else {
        return LoginResult(
          success: false,
          message: response.message ?? 'Login failed',
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return LoginResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Register new account
  Future<LoginResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.toLowerCase().trim();

      // Validate
      if (username.length < 3 || username.length > 20) {
        return LoginResult(
          success: false,
          message: 'Username must be 3-20 characters',
        );
      }

      if (!isValidEmail(trimmedEmail)) {
        return LoginResult(success: false, message: 'Invalid email format');
      }

      if (password.length < 6) {
        return LoginResult(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }

      // Call Backend API
      final response = await _apiService.register(
        username: username,
        email: trimmedEmail,
        password: password,
      );

      if (response.success && response.data != null) {
        final authData = response.data!;

        // Create auth session
        final expiry = AuthModel.calculateExpiry(rememberMe: false);

        _currentAuth = AuthModel(
          email: trimmedEmail,
          sessionToken: authData.token,
          lastLoginTime: DateTime.now(),
          rememberMe: false,
          sessionExpiry: expiry,
        );

        // Save user profile
        _userProfile = authData.user;
        await _saveUserProfile();
        await _saveAuth();
        notifyListeners();

        return LoginResult(success: true, message: 'Registration successful');
      } else {
        return LoginResult(
          success: false,
          message: response.message ?? 'Registration failed',
        );
      }
    } catch (e) {
      debugPrint('Register error: $e');
      return LoginResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      _currentAuth = null;
      _userProfile = null;
      await _box.delete(_authKey);
      await _box.delete(_userProfileKey);
      _apiService.clearAuthToken();
      // Keep saved email for next login if it exists
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
      // Try to refresh user profile
      await _refreshUserProfile();
      return true;
    } else {
      // Session expired - logout
      await logout();
      return false;
    }
  }
}

/// Login result with success status and message
class LoginResult {
  final bool success;
  final String message;

  LoginResult({required this.success, required this.message});
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/auth_model.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';
import '../models/user_profile.dart';
import '../models/auth_response.dart';

class AuthProvider with ChangeNotifier {
  static const String _boxName = 'authBox';
  static const String _authKey = 'currentAuth';
  static const String _savedEmailKey = 'savedEmail';
  static const String _userProfileKey = 'userProfile';

  late Box _box;
  AuthModel? _currentAuth;
  String? _savedEmail;
  UserProfile? _userProfile;
  
  // Dependency is now injected
  final ApiService _apiService;

  // Constructor with dependency injection
  AuthProvider(this._apiService);

  AuthModel? get currentAuth => _currentAuth;
  bool get isLoggedIn => _currentAuth?.isLoggedIn ?? false;
  String? get userEmail => _currentAuth?.email;
  String? get savedEmail => _savedEmail;
  UserProfile? get userProfile => _userProfile;
  String? get username => _userProfile?.username;
  int get totalScore => _userProfile?.totalScore ?? 0;
  int get totalGamesPlayed => _userProfile?.totalGamesPlayed ?? 0;
  String? get token => _currentAuth?.sessionToken;
  String? get userId => _userProfile?.id;
  String get userRole => _userProfile?.role ?? _currentAuth?.role ?? 'USER';
  bool get isAdmin => userRole == 'ADMIN';
  bool get isModerator => userRole == 'MODERATOR';
  bool get isAdminOrModerator => isAdmin || isModerator;

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
        debugPrint('Error loading user profile from cache: $e');
      }
    }
  }

  /// Load authentication state from Hive
  Future<void> _loadAuth() async {
    try {
      final savedAuth = _box.get(_authKey) as AuthModel?;
      if (savedAuth != null && savedAuth.isSessionValid) {
        _currentAuth = savedAuth;
        _apiService.setAuthToken(savedAuth.sessionToken);
        await _refreshUserProfile();
      } else if (savedAuth != null) {
        // Session expired - clear auth but keep saved email for "remember me"
        await _clearSession();
      }
    } catch (e) {
      debugPrint('Error loading auth: $e');
      await _clearSession();
    }
    notifyListeners();
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
      final user = await _apiService.getCurrentUser();
      _userProfile = user;
      await _saveUserProfile();
      notifyListeners();
    } on ApiException catch (e) {
      debugPrint('Error refreshing user profile: ${e.message}');
      // If token is invalid (e.g., 401), clear session but keep saved email
      if (e.statusCode == 401) {
        await _clearSession();
      }
    } catch (e) {
      debugPrint('Unhandled error refreshing user profile: $e');
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

      if (!isValidEmail(trimmedEmail)) {
        return LoginResult(success: false, message: 'Invalid email format');
      }

      final authData = await _apiService.login(
        email: trimmedEmail,
        password: password,
      );

      final expiry = AuthModel.calculateExpiry(rememberMe: rememberMe);
      _currentAuth = AuthModel(
        email: trimmedEmail,
        sessionToken: authData.token,
        lastLoginTime: DateTime.now(),
        rememberMe: rememberMe,
        sessionExpiry: expiry,
        role: authData.user.role,
      );

      _userProfile = authData.user;
      await _saveUserProfile();

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
    } on ApiException catch (e) {
      debugPrint('Login API error: ${e.message}');
      return LoginResult(success: false, message: e.message);
    } catch (e) {
      debugPrint('Login error: $e');
      return LoginResult(success: false, message: 'An unexpected error occurred.');
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

      if (username.length < 3 || username.length > 20) {
        return LoginResult(success: false, message: 'Username must be 3-20 characters');
      }
      if (!isValidEmail(trimmedEmail)) {
        return LoginResult(success: false, message: 'Invalid email format');
      }
      if (password.length < 6) {
        return LoginResult(success: false, message: 'Password must be at least 6 characters');
      }

      final authData = await _apiService.register(
        username: username,
        email: trimmedEmail,
        password: password,
      );

      final expiry = AuthModel.calculateExpiry(rememberMe: false);
      _currentAuth = AuthModel(
        email: trimmedEmail,
        sessionToken: authData.token,
        lastLoginTime: DateTime.now(),
        rememberMe: false,
        sessionExpiry: expiry,
      );

      _userProfile = authData.user;
      await _saveUserProfile();
      await _saveAuth();
      notifyListeners();

      return LoginResult(success: true, message: 'Registration successful');
    } on ApiException catch (e) {
      debugPrint('Register API error: ${e.message}');
      return LoginResult(success: false, message: e.message);
    } catch (e) {
      debugPrint('Register error: $e');
      return LoginResult(success: false, message: 'An unexpected error occurred.');
    }
  }

  /// Clear session without removing saved credentials (for expired sessions)
  Future<void> _clearSession() async {
    try {
      _currentAuth = null;
      _userProfile = null;
      await _box.delete(_authKey);
      await _box.delete(_userProfileKey);
      _apiService.clearAuthToken();
      notifyListeners();
    } catch (e) {
      debugPrint('Clear session error: $e');
    }
  }

  /// Logout and clear session
  /// Automatically preserves saved email if user had "remember me" checked
  Future<void> logout() async {
    try {
      // Check if user had "remember me" enabled
      final hadRememberMe = _currentAuth?.rememberMe ?? false;
      
      _currentAuth = null;
      _userProfile = null;
      await _box.delete(_authKey);
      await _box.delete(_userProfileKey);
      
      // Only clear saved email if user did NOT have "remember me"
      if (!hadRememberMe) {
        _savedEmail = null;
        await _box.delete(_savedEmailKey);
      }
      
      _apiService.clearAuthToken();
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
      await _refreshUserProfile();
      return true;
    } else {
      await _clearSession();
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

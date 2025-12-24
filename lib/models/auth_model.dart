import 'package:hive/hive.dart';

part 'auth_model.g.dart';

@HiveType(typeId: 5)
class AuthModel extends HiveObject {
  @HiveField(0)
  String? email;

  @HiveField(1)
  String? sessionToken;

  @HiveField(2)
  DateTime? lastLoginTime;

  @HiveField(3)
  bool rememberMe;

  @HiveField(4)
  DateTime? sessionExpiry;

  @HiveField(5)
  String? role; // USER, ADMIN, MODERATOR

  AuthModel({
    this.email,
    this.sessionToken,
    this.lastLoginTime,
    this.rememberMe = false,
    this.sessionExpiry,
    this.role = 'USER',
  });

  /// Check if session is still valid
  bool get isSessionValid {
    if (sessionToken == null || sessionExpiry == null) {
      return false;
    }
    return DateTime.now().isBefore(sessionExpiry!);
  }

  /// Check if user is logged in with valid session
  bool get isLoggedIn {
    return email != null && isSessionValid;
  }

  /// Generate a new session token (simplified version)
  static String generateToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${email}_${timestamp}_${timestamp.hashCode}';
  }

  /// Create session expiry based on remember me preference
  static DateTime calculateExpiry({bool rememberMe = false}) {
    final now = DateTime.now();
    if (rememberMe) {
      return now.add(const Duration(days: 30)); // 30 days for remember me
    } else {
      return now.add(const Duration(hours: 24)); // 24 hours default
    }
  }

  @override
  String toString() {
    return 'AuthModel(email: $email, rememberMe: $rememberMe, isLoggedIn: $isLoggedIn)';
  }
}

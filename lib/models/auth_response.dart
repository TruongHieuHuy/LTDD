import './user_profile.dart';

/// Auth response after login/register
class AuthResponse {
  final UserProfile? user;
  final String? token;
  final bool requiresTwoFactor;
  final String? userId; // For 2FA flow
  final String? message;

  AuthResponse({
    this.user,
    this.token,
    this.requiresTwoFactor = false,
    this.userId,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      token: json['token'],
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      userId: json['userId'],
      message: json['message'],
    );
  }
}

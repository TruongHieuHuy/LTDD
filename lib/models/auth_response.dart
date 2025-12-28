import './user_profile.dart';

/// Auth response after login/register
class AuthResponse {
  final UserProfile user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserProfile.fromJson(json['user']),
      token: json['token'],
    );
  }
}

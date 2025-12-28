import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_client.dart';
import '../models/auth_response.dart';
import '../models/user_profile.dart';

/// Service for handling authentication-related API calls.
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Pass-through to set the auth token on the ApiClient.
  void setToken(String? token) {
    _apiClient.setAuthToken(token);
  }

  /// Pass-through to clear the auth token on the ApiClient.
  void clearToken() {
    _apiClient.clearAuthToken();
  }

  /// Register new user
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final authData = await _apiClient.request<AuthResponse>(
      'Register',
      httpRequest: () => http.post(
        Uri.parse('${ApiClient.baseUrl}/api/auth/register'),
        headers: _apiClient.headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ),
      onSuccess: (data) => AuthResponse.fromJson(data['data']),
      defaultErrorMessage: 'Registration failed',
    );
    _apiClient.setAuthToken(authData.token); // Save token
    return authData;
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final authData = await _apiClient.request<AuthResponse>(
      'Login',
      httpRequest: () => http.post(
        Uri.parse('${ApiClient.baseUrl}/api/auth/login'),
        headers: _apiClient.headers,
        body: jsonEncode({'email': email, 'password': password}),
      ),
      onSuccess: (data) => AuthResponse.fromJson(data['data']),
      defaultErrorMessage: 'Login failed',
    );
    _apiClient.setAuthToken(authData.token); // Save token
    return authData;
  }

  /// Get current user profile
  Future<UserProfile> getCurrentUser() => _apiClient.request(
        'GetCurrentUser',
        httpRequest: () => http.get(
          Uri.parse('${ApiClient.baseUrl}/api/auth/me'),
          headers: _apiClient.headers,
        ),
        onSuccess: (data) => UserProfile.fromJson(data['data']['user']),
        defaultErrorMessage: 'Failed to get user',
      );

  /// Forgot Password - Send reset token
  Future<Map<String, dynamic>> forgotPassword({required String email}) =>
      _apiClient.request(
        'ForgotPassword',
        httpRequest: () => http.post(
          Uri.parse('${ApiClient.baseUrl}/api/auth/forgot-password'),
          headers: _apiClient.headers,
          body: jsonEncode({'email': email}),
        ),
        onSuccess: (data) => (data['data'] as Map<String, dynamic>?) ?? {},
        defaultErrorMessage: 'Failed to send reset token',
      );

  /// Reset Password - With token
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) =>
      _apiClient.request(
        'ResetPassword',
        httpRequest: () => http.post(
          Uri.parse('${ApiClient.baseUrl}/api/auth/reset-password'),
          headers: _apiClient.headers,
          body: jsonEncode({
            'email': email,
            'resetToken': token,
            'newPassword': newPassword,
          }),
        ),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to reset password',
      );

  /// Update Profile - Username and Avatar
  Future<UserProfile> updateProfile({String? username, String? avatarUrl}) {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    return _apiClient.request(
      'UpdateProfile',
      httpRequest: () => http.put(
        Uri.parse('${ApiClient.baseUrl}/api/auth/profile'),
        headers: _apiClient.headers,
        body: jsonEncode(body),
      ),
      onSuccess: (data) => UserProfile.fromJson(data['data']['user']),
      defaultErrorMessage: 'Failed to update profile',
    );
  }

  /// Change Password - Requires current password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _apiClient.request(
        'ChangePassword',
        httpRequest: () => http.post(
          Uri.parse('${ApiClient.baseUrl}/api/auth/change-password'),
          headers: _apiClient.headers,
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        ),
        onSuccess: (_) {},
        defaultErrorMessage: 'Failed to change password',
      );
}

/// Custom exception for API-related errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message (Status code: $statusCode)';
  }
}

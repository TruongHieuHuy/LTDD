import '../config/config_url.dart';

/// Helper functions for URL manipulation
class UrlHelper {
  /// Convert relative URL to absolute URL
  /// If URL starts with '/', prepend base URL
  /// Otherwise return the URL as is
  static String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    if (url.startsWith('/')) {
      return '${ConfigUrl.baseUrl}$url';
    }

    return url;
  }
}

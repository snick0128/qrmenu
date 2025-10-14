import 'package:flutter/foundation.dart';

class URLUtils {
  /// Extracts hotelId and tableNo from a URL path
  /// Format: /{hotelId}/{tableNo}
  static Map<String, String?> extractParams(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    return {
      'hotelId': parts.isNotEmpty ? parts[0] : null,
      'tableNo': parts.length > 1 ? parts[1] : null,
    };
  }

  /// Validates URL parameters
  static bool validateParams(String? hotelId, String? tableNo) {
    if (hotelId == null || hotelId.isEmpty) {
      debugPrint('❌ Invalid URL: Missing hotelId');
      return false;
    }

    // TableNo is optional since we have a manual entry fallback
    return true;
  }

  /// Builds a valid URL for the menu
  static String buildMenuUrl(String hotelId, String tableNo) {
    return '/$hotelId/$tableNo';
  }

  /// Builds a valid URL for manual entry with restaurant pre-filled
  static String buildManualEntryUrl(String hotelId) {
    return '/$hotelId';
  }

  /// Gets base URL for the app
  static String get baseUrl {
    if (kIsWeb) {
      final url = Uri.base;
      return '${url.scheme}://${url.host}${url.port != 80 && url.port != 443 ? ':${url.port}' : ''}';
    }
    return 'https://appurl.netlify.app'; // Default production URL
  }

  /// Gets full URL for sharing
  static String getFullUrl(String path) {
    return '$baseUrl$path';
  }
}

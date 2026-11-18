import 'dart:convert';

class WebStateSerializer {
  static String encodeState(String jsonStr) {
    return base64Url.encode(utf8.encode(jsonStr));
  }

  static String? decodeState(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) return null;
    final trimmed = encoded.trim();

    // 1. Try URL-safe base64
    try {
      final normalizedUrl = base64Url.normalize(trimmed);
      return utf8.decode(base64Url.decode(normalizedUrl));
    } catch (_) {}

    // 2. Try standard base64 with space-to-plus restoration
    try {
      final sanitized = trimmed.replaceAll(' ', '+');
      final normalized = base64.normalize(sanitized);
      return utf8.decode(base64Decode(normalized));
    } catch (_) {}

    return null;
  }
}

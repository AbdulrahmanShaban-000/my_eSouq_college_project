import 'package:zad/core/api/end_points.dart';

class ImageUrlHelper {
  static String get _baseUrl => EndPoints.baseUrl
      .replaceFirst(RegExp(r'/api/?$'), '')
      .replaceFirst(RegExp(r'/+$'), '');

  static String getFullUrl(String? apiPath) {
    final path = apiPath?.trim();
    if (path == null || path.isEmpty) {
      return '';
    }

    final parsedUri = Uri.tryParse(path);
    if (parsedUri != null && parsedUri.hasScheme && parsedUri.host.isNotEmpty) {
      if (!_isLocalHost(parsedUri.host)) return path;

      final baseUri = Uri.parse(_baseUrl);
      var rewrittenUri = baseUri.replace(path: parsedUri.path);
      if (parsedUri.hasQuery) {
        rewrittenUri = rewrittenUri.replace(query: parsedUri.query);
      }
      if (parsedUri.hasFragment) {
        rewrittenUri = rewrittenUri.replace(fragment: parsedUri.fragment);
      }
      return rewrittenUri.toString();
    }

    var cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // Laravel's public disk is exposed through the public /storage URL.
    cleanPath = cleanPath.replaceFirst(
      RegExp(r'^storage/app/public/?'),
      'storage/',
    );

    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }

    return '$_baseUrl/$cleanPath';
  }

  static bool _isLocalHost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0' ||
        host == '::1';
  }
}

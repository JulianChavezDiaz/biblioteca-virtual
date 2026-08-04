/// Configuración del backend HTTP (reemplaza a Supabase).
///
/// La URL base se puede sobreescribir en build/run con:
///   flutter run -d chrome --dart-define=API_BASE_URL=https://mi-api.com/api
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  /// Convierte cualquier archivo local de `/uploads` en una URL absoluta
  /// usando el mismo servidor configurado para la API.
  ///
  /// También corrige registros antiguos guardados como `uploads/...` o con
  /// otro host (por ejemplo, `http://localhost:4000/uploads/...`).
  static String resolvePublicUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return url;

    final parsed = Uri.tryParse(url);
    String? uploadPath;

    if (url.startsWith('/uploads/')) {
      uploadPath = url;
    } else if (url.startsWith('uploads/')) {
      uploadPath = '/$url';
    } else if (parsed != null &&
        parsed.hasScheme &&
        parsed.path.startsWith('/uploads/')) {
      uploadPath = parsed.path;
    }

    if (uploadPath == null) return url;

    final apiUri = Uri.parse(baseUrl);
    var basePath = apiUri.path.replaceFirst(RegExp(r'/api/?$'), '');
    if (basePath.endsWith('/')) {
      basePath = basePath.substring(0, basePath.length - 1);
    }

    final publicUri = apiUri.replace(
      path: '$basePath$uploadPath',
      query: null,
      fragment: null,
    );
    return publicUri.toString();
  }
}

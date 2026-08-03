/// Configuración del backend HTTP (reemplaza a Supabase).
///
/// La URL base se puede sobreescribir en build/run con:
///   flutter run -d chrome --dart-define=API_BASE_URL=https://mi-api.com/api
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );
}

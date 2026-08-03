/// Error de la capa de API. `message` ya viene legible desde el backend
/// (campo `{ "error": "..." }`).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

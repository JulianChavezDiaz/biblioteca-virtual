import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Cliente HTTP central contra el backend Next.js.
/// Inyecta el JWT en cada petición y normaliza los errores a [ApiException].
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  String? _token;

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Carga el token guardado al iniciar la app.
  Future<void> init() async {
    _token = await TokenStorage.getToken();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await TokenStorage.saveToken(token);
  }

  Future<void> clearToken() async {
    _token = null;
    await TokenStorage.clear();
  }

  // ---- Métodos genéricos -------------------------------------------------

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) =>
      _request(() => _dio.post(path, data: data));

  Future<dynamic> put(String path, {Object? data}) =>
      _request(() => _dio.put(path, data: data));

  Future<dynamic> patch(String path, {Object? data}) =>
      _request(() => _dio.patch(path, data: data));

  Future<dynamic> delete(String path) =>
      _request(() => _dio.delete(path));

  /// Sube un archivo (multipart) y devuelve la URL pública.
  /// Reemplaza a Supabase Storage.
  Future<String> uploadFile(
    List<int> bytes,
    String filename, {
    required String folder,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'folder': folder,
    });
    final data = await _request(() => _dio.post('/uploads', data: form));
    return Map<String, dynamic>.from(data as Map)['url'] as String;
  }

  // ---- Ayudas tipadas ----------------------------------------------------

  /// GET que devuelve una lista de objetos.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final data = await get(path, query: query);
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// GET que devuelve un objeto.
  Future<Map<String, dynamic>> getMap(String path) async {
    final data = await get(path);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<dynamic> _request(Future<Response> Function() send) async {
    try {
      final res = await send();
      return res.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : (e.message ?? 'Error de red');
      throw ApiException(message, e.response?.statusCode);
    }
  }
}

import 'dart:convert';
import '../api/api_client.dart';
import '../api/token_storage.dart';
import '../models/user_model.dart' as app_user;
import 'enum_converter.dart';

/// Servicio de autenticación contra el backend Next.js (JWT).
///
/// Nota: el nombre se mantiene como `SupabaseAuthService` para no romper los
/// imports/usos existentes en las pantallas. Ya NO usa Supabase.
/// Es un singleton para que `currentUser` se comparta en toda la app.
class SupabaseAuthService {
  SupabaseAuthService._();
  static final SupabaseAuthService _instance = SupabaseAuthService._();
  factory SupabaseAuthService() => _instance;

  final _api = ApiClient.instance;
  app_user.User? _currentUser;

  app_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  app_user.User _userFromJson(Map<String, dynamic> json) {
    return app_user.User(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? 'Usuario',
      role: EnumConverter.parseUserRole(json['role']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    await _api.setToken(data['token'] as String);
    final userMap = Map<String, dynamic>.from(data['user'] as Map);
    _currentUser = _userFromJson(userMap);
    await TokenStorage.saveUser(jsonEncode(userMap));
  }

  Future<bool> register(String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      print('Error: Campos vacíos');
      return false;
    }
    if (password.length < 6) {
      print('Error: Contraseña debe tener al menos 6 caracteres');
      return false;
    }
    try {
      final data = await _api.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
      await _handleAuthResponse(Map<String, dynamic>.from(data as Map));
      return true;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final data = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _handleAuthResponse(Map<String, dynamic>.from(data as Map));
      return true;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  /// Restaura la sesión desde el token guardado. Devuelve true si sigue válido.
  Future<bool> restoreSession() async {
    await _api.init();
    if (!_api.hasToken) return false;
    try {
      final data = await _api.getMap('/auth/me');
      _currentUser = _userFromJson(Map<String, dynamic>.from(data['user'] as Map));
      return true;
    } catch (e) {
      print('Sesión inválida o expirada: $e');
      await _api.clearToken();
      return false;
    }
  }

  /// El usuario actual actualiza su propio nombre y/o contraseña.
  Future<void> updateProfile({String? name, String? password}) async {
    final data = <String, dynamic>{};
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (password != null && password.isNotEmpty) data['password'] = password;
    if (data.isEmpty) return;
    final res = await _api.patch('/auth/me', data: data);
    // Refrescar el usuario en memoria.
    final map = Map<String, dynamic>.from(res as Map);
    if (map['user'] != null) {
      _currentUser = _userFromJson(Map<String, dynamic>.from(map['user'] as Map));
    }
  }

  Future<void> resetPassword(String email) async {
    await _api.post('/auth/reset-password', data: {'email': email});
  }

  /// Confirma el restablecimiento con el token recibido por correo.
  Future<void> confirmResetPassword(String token, String password) async {
    await _api.post(
      '/auth/reset-password/confirm',
      data: {'token': token, 'password': password},
    );
  }

  Future<void> logout() async {
    await _api.clearToken();
    _currentUser = null;
  }
}

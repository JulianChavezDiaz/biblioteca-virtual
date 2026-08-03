import '../api/api_client.dart';

/// Gestión de usuarios vía API HTTP (solo staff/admin según el backend).
class UserService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      return await _api.getList('/users');
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<void> updateRole(String id, String role) async {
    await _api.patch('/users/$id', data: {'role': role});
  }

  /// Actualiza nombre y/o contraseña de un usuario (solo admin en el backend).
  Future<void> updateUser(String id, {String? name, String? password}) async {
    final data = <String, dynamic>{};
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (password != null && password.isNotEmpty) data['password'] = password;
    if (data.isEmpty) return;
    await _api.patch('/users/$id', data: data);
  }

  /// Info básica de un usuario ({ id, name, role }).
  Future<Map<String, dynamic>?> getUser(String id) async {
    try {
      return await _api.getMap('/users/$id');
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/users/$id');
  }
}

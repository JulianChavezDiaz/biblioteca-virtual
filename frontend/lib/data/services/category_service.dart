import '../api/api_client.dart';

/// Acceso a categorías vía API HTTP.
class CategoryService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      return await _api.getList('/categories');
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createCategory({
    required String name,
    String? description,
  }) async {
    final res = await _api.post('/categories', data: {
      'name': name,
      'description': description,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  Future<void> updateCategory(
    String id, {
    required String name,
    String? description,
  }) async {
    await _api.put('/categories/$id', data: {
      'name': name,
      'description': description,
    });
  }

  /// Borrado lógico (is_active = false).
  Future<void> deleteCategory(String id) async {
    await _api.delete('/categories/$id');
  }
}

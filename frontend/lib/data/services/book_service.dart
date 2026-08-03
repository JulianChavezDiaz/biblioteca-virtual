import '../api/api_client.dart';

/// Acceso a libros vía API HTTP. Devuelve mapas en snake_case (igual que antes
/// devolvía Supabase), por lo que `BookModel.fromJson` funciona sin cambios.
class BookService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getBooks({
    String? search,
    String? category,
    int? limit,
    bool physicalOnly = false,
  }) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (limit != null) query['limit'] = limit;
    if (physicalOnly) query['physical'] = '1';
    try {
      return await _api.getList('/books', query: query);
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBook(String id) async {
    try {
      return await _api.getMap('/books/$id');
    } catch (e) {
      print('Error fetching book $id: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createBook(Map<String, dynamic> data) async {
    final res = await _api.post('/books', data: data);
    return Map<String, dynamic>.from(res as Map);
  }

  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    await _api.put('/books/$id', data: data);
  }

  Future<void> deleteBook(String id) async {
    await _api.delete('/books/$id');
  }
}

import '../api/api_client.dart';
import 'cache_service.dart';

/// Servicio para registrar y obtener estadísticas de lectura (vía API HTTP).
class StatsService {
  final _api = ApiClient.instance;

  static const String _recentBooksKey = 'recent_books_stats';
  static const String _topBooksKey = 'top_books_stats';

  /// Registra la apertura de un libro
  Future<void> recordBookOpen(String bookId) async {
    try {
      await _api.post('/books/$bookId/open');
      CacheService.remove(_topBooksKey);
    } catch (e) {
      print('Error recording book open: $e');
    }
  }

  /// Actualiza el progreso de lectura del usuario
  Future<void> updateReadingProgress(String bookId, int progress) async {
    try {
      await _api.post(
        '/reading-progress',
        data: {'bookId': bookId, 'progress': progress},
      );
      CacheService.remove(_recentBooksKey);
    } catch (e) {
      print('Error updating reading progress: $e');
    }
  }

  /// Obtiene los libros recientemente leídos por el usuario actual
  Future<List<Map<String, dynamic>>> getRecentBooks() async {
    final cached = CacheService.get<List<Map<String, dynamic>>>(_recentBooksKey);
    if (cached != null) return cached;

    try {
      final result = await _api.getList('/stats/recent');
      CacheService.set(_recentBooksKey, result);
      return result;
    } catch (e) {
      print('Error fetching recent books: $e');
      return [];
    }
  }

  /// Top libros con un límite personalizado (sin caché) — para reportes/CSV.
  Future<List<Map<String, dynamic>>> getTopBooksRaw({int limit = 15}) async {
    try {
      return await _api.getList('/stats/top-books', query: {'limit': limit});
    } catch (e) {
      print('Error fetching top books (raw): $e');
      return [];
    }
  }

  /// Obtiene los libros más populares
  Future<List<Map<String, dynamic>>> getTopBooks() async {
    final cached = CacheService.get<List<Map<String, dynamic>>>(_topBooksKey);
    if (cached != null) return cached;

    try {
      final result = await _api.getList('/stats/top-books');
      CacheService.set(_topBooksKey, result);
      return result;
    } catch (e) {
      print('Error fetching top books: $e');
      return [];
    }
  }
}

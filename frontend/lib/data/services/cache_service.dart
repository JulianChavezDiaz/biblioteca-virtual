/// Servicio de caché genérico para datos de la aplicación
class CacheService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Obtiene un valor del caché si es válido
  static T? get<T>(String key) {
    if (_isValidCache(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  /// Almacena un valor en caché
  static void set<T>(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Verifica si una clave está en caché y es válida
  static bool isValid(String key) => _isValidCache(key);

  /// Valida si el caché no ha expirado
  static bool _isValidCache(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Limpia todo el caché
  static void clearAll() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Elimina una clave específica del caché
  static void remove(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
}
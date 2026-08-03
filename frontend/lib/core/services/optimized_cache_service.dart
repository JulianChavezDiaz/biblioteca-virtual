import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OptimizedCacheService {
  static OptimizedCacheService? _instance;
  static OptimizedCacheService get instance => _instance ??= OptimizedCacheService._();
  OptimizedCacheService._();

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  static const Duration _defaultTTL = Duration(minutes: 15);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Caché en memoria para acceso rápido
  T? getFromMemory<T>(String key) {
    if (_memoryCache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && DateTime.now().difference(timestamp) < _defaultTTL) {
        return _memoryCache[key] as T?;
      } else {
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  void setInMemory<T>(String key, T value) {
    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Caché persistente
  Future<T?> get<T>(String key) async {
    await init();
    
    // Primero verificar memoria
    final memoryValue = getFromMemory<T>(key);
    if (memoryValue != null) return memoryValue;

    // Luego verificar almacenamiento persistente
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString);
        final timestamp = DateTime.parse(data['timestamp']);
        
        if (DateTime.now().difference(timestamp) < _defaultTTL) {
          final value = data['value'] as T;
          setInMemory(key, value); // Guardar en memoria para próxima vez
          return value;
        } else {
          await _prefs?.remove(key);
        }
      } catch (e) {
        await _prefs?.remove(key);
      }
    }
    return null;
  }

  Future<void> set<T>(String key, T value) async {
    await init();
    
    setInMemory(key, value);
    
    final data = {
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _prefs?.setString(key, jsonEncode(data));
  }

  Future<void> remove(String key) async {
    await init();
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    await _prefs?.remove(key);
  }

  void clearMemory() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }
}
import 'package:flutter/material.dart';

/// Servicio para cargar widgets de forma lazy con caché
class LazyLoadingService {
  static final Map<String, Widget> _cache = {};
  static final Map<String, Future<Widget>> _loading = {};

  /// Carga un widget de forma lazy con caché
  /// Si el widget ya está en caché, lo devuelve inmediatamente
  /// Si se está cargando, espera a que termine
  static Future<Widget> loadWidget(
    String key,
    Future<Widget> Function() builder,
  ) async {
    // Si ya está en caché, devolverlo inmediatamente
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Si ya se está cargando, esperar a que termine
    if (_loading.containsKey(key)) {
      return await _loading[key]!;
    }

    // Iniciar la carga
    final future = builder();
    _loading[key] = future;

    try {
      final widget = await future;
      _cache[key] = widget;
      _loading.remove(key);
      return widget;
    } catch (e) {
      _loading.remove(key);
      rethrow;
    }
  }

  /// Widget que carga de forma lazy con FutureBuilder
  static Widget lazyWidget(
    String key,
    Future<Widget> Function() builder, {
    Widget? placeholder,
  }) {
    return FutureBuilder<Widget>(
      future: loadWidget(key, builder),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        return placeholder ?? const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  /// Precargar widgets en background
  static void preloadWidget(String key, Future<Widget> Function() builder) {
    if (!_cache.containsKey(key) && !_loading.containsKey(key)) {
      loadWidget(key, builder).catchError((e) {
        print('Error preloading widget $key: $e');
      });
    }
  }

  /// Limpia todo el caché
  static void clearCache() {
    _cache.clear();
    _loading.clear();
  }

  /// Elimina un widget específico del caché
  static void removeFromCache(String key) {
    _cache.remove(key);
    _loading.remove(key);
  }
}

/// Widget optimizado para listas grandes
class LazyListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;

  const LazyListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.padding,
  });

  @override
  State<LazyListView> createState() => _LazyListViewState();
}

class _LazyListViewState extends State<LazyListView> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _loadedItems = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        // Marcar como cargado cuando se construye
        _loadedItems.add(index);
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Mixin para widgets que necesitan lazy loading
mixin LazyLoadingMixin<T extends StatefulWidget> on State<T> {
  final Map<String, dynamic> _lazyData = {};
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Cargar datos de forma lazy
  Future<U> loadLazy<U>(
    String key,
    Future<U> Function() loader,
  ) async {
    if (_lazyData.containsKey(key)) {
      return _lazyData[key] as U;
    }

    final data = await loader();
    
    if (!_isDisposed) {
      _lazyData[key] = data;
    }
    
    return data;
  }

  /// Verificar si los datos están cargados
  bool isLoaded(String key) => _lazyData.containsKey(key);

  /// Obtener datos cargados
  U? getLazy<U>(String key) => _lazyData[key] as U?;

  /// Limpiar datos lazy
  void clearLazy() => _lazyData.clear();
}
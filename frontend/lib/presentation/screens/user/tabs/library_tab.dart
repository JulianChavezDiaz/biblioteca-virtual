import 'package:flutter/material.dart';
import '../../../../data/services/book_service.dart';
import '../../../../data/services/category_service.dart';
import '../../../../core/theme/optimized_theme.dart';
import '../../../../core/services/optimized_cache_service.dart';
import '../category_books_view.dart';
import '../../../widgets/category_accordion.dart';
import '../../../widgets/book_list_widget.dart';

class LibraryTab extends StatefulWidget {
  final String searchQuery;
  final bool canEdit;
  final String userRole;

  const LibraryTab({
    super.key,
    this.searchQuery = '',
    required this.canEdit,
    required this.userRole,
  });

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final _bookService = BookService();
  final _categoryService = CategoryService();
  String? selectedCategory;
  bool showCategoryAccordion = false;
  Map<String, List<String>> categories = {};
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _categoryService.getCategories();

      setState(() {
        categories = {};
        for (var category in response) {
          categories[category['name']] = [
            'General'
          ]; // Subcategoría por defecto
        }
        _loadingCategories = false;
      });
    } catch (e) {
      print('Error cargando categorías: $e');
      setState(() => _loadingCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCategory != null) {
      return CategoryBooksView(
        category: selectedCategory!,
        onBack: () => setState(() => selectedCategory = null),
        canEdit: widget.canEdit,
        userRole: widget.userRole,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingCategories)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            CategoryAccordion(
              categories: categories,
              showAccordion: showCategoryAccordion,
              onToggle: () => setState(
                  () => showCategoryAccordion = !showCategoryAccordion),
              onCategorySelected: (category) => setState(() {
                selectedCategory = category;
                showCategoryAccordion = false;
              }),
            ),
          const SizedBox(height: 32),
          _buildBookSection('Top 10 Libros', _getTopBooks()),
          const SizedBox(height: 32),
          _buildBookSection('Libros Recientes', _getRecentBooks()),
          const SizedBox(height: 32),
          _buildBookSection('Libros Sugeridos',
              _getRecentBooks().then((data) => data.take(5).toList())),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getTopBooks() async {
    const cacheKey = 'top_books';

    // Verificar caché primero
    final cached = await OptimizedCacheService.instance
        .get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _bookService.getBooks(limit: 10);

      // Guardar en caché
      await OptimizedCacheService.instance.set(cacheKey, response);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentBooks() async {
    const cacheKey = 'recent_books';

    final cached = await OptimizedCacheService.instance
        .get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _bookService.getBooks(limit: 20);

      await OptimizedCacheService.instance.set(cacheKey, response);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getBooksWithPagination(
      int page, int limit) async {
    final cacheKey = 'books_page_${page}_$limit';

    final cached = await OptimizedCacheService.instance
        .get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    try {
      // Nota: la paginación por rango se simplifica a un límite; el backend
      // aún no expone offset/range.
      final response = await _bookService.getBooks(limit: limit);

      await OptimizedCacheService.instance.set(cacheKey, response);
      return response;
    } catch (e) {
      return [];
    }
  }

  Widget _buildBookSection(
      String title, Future<List<Map<String, dynamic>>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OptimizedTheme.heading3
              .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        BookListWidget(
          future: future,
          canEdit: widget.canEdit,
          userRole: widget.userRole,
          onRefresh: () => setState(() {}),
        ),
      ],
    );
  }
}

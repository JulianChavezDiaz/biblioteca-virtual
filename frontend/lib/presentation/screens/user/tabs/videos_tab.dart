import 'package:flutter/material.dart';
import '../../../../core/theme/optimized_theme.dart';
import '../../../../data/services/video_service.dart';
import '../../../../data/services/category_service.dart';
import '../category_videos_view.dart';
import '../../../widgets/category_accordion.dart';
import '../../../widgets/video_list_widget.dart';

class VideosTab extends StatefulWidget {
  final String searchQuery;
  final bool canEdit;
  final String userRole;

  const VideosTab({
    super.key,
    this.searchQuery = '',
    required this.canEdit,
    required this.userRole,
  });

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  final _videoService = VideoService();
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
      return CategoryVideosView(
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
          _buildVideoSection('Top 10 Videos', _getRecentVideos()),
          const SizedBox(height: 32),
          _buildVideoSection('Videos Recientes', _getRecentVideos()),
          const SizedBox(height: 32),
          _buildVideoSection('Videos Recomendados',
              _getRecentVideos().then((data) => data.take(3).toList())),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getRecentVideos() async {
    try {
      return await _videoService.getVideos();
    } catch (e) {
      return [];
    }
  }

  Widget _buildVideoSection(
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
        VideoListWidget(
          future: future,
          canEdit: widget.canEdit,
          userRole: widget.userRole,
          onRefresh: () => setState(() {}),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/optimized_theme.dart';
import '../../../widgets/common_widgets.dart';

class HomeTab extends StatelessWidget {
  final String searchQuery;

  const HomeTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 32),
          _buildTopBooksSection(),
          const SizedBox(height: 32),
          _buildSection('Libros Recientes', DataService.getRecentBooks()),
          const SizedBox(height: 24),
          _buildSection('Videos Recientes', DataService.getRecentVideos(),
              isVideo: true),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppColors.primaryShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¡Bienvenido!',
                      style: OptimizedTheme.heading1.copyWith(
                        // Header siempre tiene fondo oscuro (gradient), mantener blanco
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre miles de libros y videos educativos',
                      style: OptimizedTheme.bodyText.copyWith(
                        // Header mantiene blanco
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/1.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white.withOpacity(0.1),
                      child: const Icon(Icons.auto_stories,
                          size: 40, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBooksSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 300,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.yaviracOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Top 10 Más Leídos',
                  style: OptimizedTheme.heading3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: HorizontalBookList(
                future: DataService.getTopBooks(),
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<List<Map<String, dynamic>>> future,
      {bool isVideo = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 8),
        HorizontalBookList(
          future: future,
          searchQuery: searchQuery,
          isVideoList: isVideo,
        ),
      ],
    );
  }
}

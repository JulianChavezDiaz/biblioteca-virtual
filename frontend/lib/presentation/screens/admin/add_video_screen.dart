import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../theme/glass_theme.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/services/video_service.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Desarrollo de Software';
  String _selectedSubcategory = 'Frontend';
  bool _isLoading = false;

  final Map<String, List<String>> _categories = {
    'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
    'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
    'Guía Nacional de Turismo': [
      'Destinos',
      'Hoteles',
      'Restaurantes',
      'Actividades'
    ],
    'Arte Culinaria': [
      'Cocina Nacional',
      'Cocina Internacional',
      'Repostería',
      'Bebidas'
    ],
    'Idioma': ['Inglés', 'Francés', 'Alemán', 'Portugués'],
  };

  String _extractYouTubeId(String url) {
    final regExp =
        RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? url;
  }

  Future<void> _addVideo() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y URL del video')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await VideoService().createVideo({
        'title': _titleController.text,
        'video_id': _urlController.text,
        'thumbnail_url': _thumbnailController.text.isEmpty
            ? null
            : _thumbnailController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
      });

      if (mounted) {
        CacheService.remove('recent_videos');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video agregado exitosamente',
                style: GoogleFonts.outfit()),
            backgroundColor: GlassTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e', style: GoogleFonts.outfit()),
            backgroundColor: Colors.redAccent),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.yaviracBlue,
              AppColors.yaviracBlueDark,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yaviracOrange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGREGAR VIDEO',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Enriquece el contenido multimedia',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.yaviracOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.yaviracOrange.withOpacity(0.5),
                ),
              ),
              child: const Icon(Icons.video_library,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.yaviracOrange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información del Video', Icons.info_outline),
            const SizedBox(height: 20),
            _buildVideoInfo(),
            const SizedBox(height: 30),
            _buildSectionTitle(
                'Contenido Multimedia', Icons.play_circle_outline),
            const SizedBox(height: 20),
            _buildMediaSection(),
            const SizedBox(height: 30),
            _buildSectionTitle('Categorización', Icons.category),
            const SizedBox(height: 20),
            _buildCategorySection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.avatarGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.yaviracOrange,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      children: [
        _buildInput(
            _titleController, 'Título del Video', Icons.video_library, 0),
        const SizedBox(height: 16),
        _buildInput(_descriptionController, 'Descripción',
            Icons.description_outlined, 100,
            maxLines: 3),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      children: [
        _buildInput(_urlController, 'URL del Video (YouTube, Vimeo, etc.)',
            Icons.link, 200),
        const SizedBox(height: 16),
        _buildInput(_thumbnailController, 'URL de Miniatura (opcional)',
            Icons.image_outlined, 300),
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.yaviracOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.yaviracOrange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.yaviracOrange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Soporta enlaces de YouTube, Vimeo y otros servicios de video',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            _selectedCategory,
            'Categoría',
            _categories.keys.toList(),
            (value) => setState(() {
              _selectedCategory = value!;
              _selectedSubcategory = _categories[value]!.first;
            }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdown(
            _selectedSubcategory,
            'Subcategoría',
            _categories[_selectedCategory]!,
            (value) => setState(() => _selectedSubcategory = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon, int delay,
      {int maxLines = 1}) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.yaviracOrange.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.yaviracOrange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
            prefixIcon: Icon(icon, color: AppColors.yaviracOrange, size: 20),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.yaviracOrange, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, String label, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.yaviracOrange.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.yaviracOrange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.yaviracOrange, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dropdownColor: AppColors.yaviracBlueDark,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: GoogleFonts.outfit(color: Colors.white)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: FadeInUp(
        delay: const Duration(milliseconds: 400),
        child: Container(
          width: 300,
          height: 55,
          decoration: BoxDecoration(
            gradient: AppColors.sidebarGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.yaviracOrange.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _addVideo,
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_library, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'AGREGAR VIDEO',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

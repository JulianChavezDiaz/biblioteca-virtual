import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final String? selectedSubcategory;
  final bool showFilter;
  final Function(String, String) onCategorySelected;
  final VoidCallback onToggleFilter;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    this.selectedSubcategory,
    required this.showFilter,
    required this.onCategorySelected,
    required this.onToggleFilter,
  });

  final Map<String, List<String>> _categories = const {
    'Todas': ['Todas'],
    'Desarrollo de Software': [
      'Todas',
      'Frontend',
      'Backend',
      'Móvil',
      'Base de Datos'
    ],
    'Marketing': ['Todas', 'Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
    'Guía Nacional de Turismo': [
      'Todas',
      'Destinos',
      'Hoteles',
      'Restaurantes',
      'Actividades'
    ],
    'Arte Culinaria': [
      'Todas',
      'Cocina Nacional',
      'Cocina Internacional',
      'Repostería',
      'Bebidas'
    ],
    'Idioma': ['Todas', 'Inglés', 'Francés', 'Alemán', 'Portugués'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggleFilter,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.category, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  selectedCategory,
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
                const Spacer(),
                Icon(showFilter ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70),
              ],
            ),
          ),
        ),
        if (showFilter)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _categories.keys
                  .map((category) => ListTile(
                        title: Text(category,
                            style: GoogleFonts.outfit(color: Colors.white)),
                        onTap: () => onCategorySelected(category, 'Todas'),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

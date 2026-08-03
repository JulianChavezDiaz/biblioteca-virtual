import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/book_service.dart';
import 'book_detail_screen.dart';

class CategoryBooksView extends StatelessWidget {
  final String category;
  final VoidCallback onBack;
  final bool canEdit;
  final String userRole;

  const CategoryBooksView({
    super.key,
    required this.category,
    required this.onBack,
    required this.canEdit,
    required this.userRole,
  });

  Future<List<Map<String, dynamic>>> _loadBooks() async {
    try {
      return await BookService().getBooks(category: category);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón volver
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Volver', style: GoogleFonts.outfit(color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Título de categoría
          Text(
            category,
            style: GoogleFonts.outfit(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),

          // Todos los libros de la categoría
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                );
              }

              final books = snapshot.data ?? [];
              if (books.isEmpty) {
                return SizedBox(
                  height: 150,
                  child: Center(
                    child: Text('No hay libros en esta categoría',
                        style: GoogleFonts.outfit(color: Colors.white70)),
                  ),
                );
              }

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: books.map((book) {
                  return SizedBox(
                    width: 160,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: (book['cover_url'] != null &&
                                      book['cover_url'].toString().isNotEmpty)
                                  ? Image.network(
                                      book['cover_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey,
                                        child: const Icon(Icons.book, size: 40),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey,
                                      child: const Icon(Icons.book, size: 40),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                book['title'] ?? 'Sin título',
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

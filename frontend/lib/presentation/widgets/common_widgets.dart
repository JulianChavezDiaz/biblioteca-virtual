import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../data/services/book_service.dart';
import '../../data/services/video_service.dart';
import '../screens/user/book_detail_screen.dart';
import '../screens/user/mobile_video_player.dart';

// Widgets const reutilizables
class AppWidgets {
  static const loadingIndicator = Center(
    child: CircularProgressIndicator(color: Colors.white),
  );

  static const noDataText = Center(
    child: Text(
      'Cargando contenido...',
      style: TextStyle(color: Colors.white70),
    ),
  );
}

// Widget optimizado para tarjetas de videos
class VideoCard extends StatelessWidget {
  final Map<String, dynamic> video;
  final double width;
  final double height;

  const VideoCard({
    super.key,
    required this.video,
    this.width = 140,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileVideoPlayer(video: video),
        ),
      ),
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: video['thumbnail_url'] != null
                        ? Image.network(
                            video['thumbnail_url'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.video_library,
                                  size: 40, color: Colors.white54),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.video_library,
                                size: 40, color: Colors.white54),
                          ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      video['title'] ?? 'Sin título',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      video['channel'] ?? 'Canal desconocido',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget optimizado para tarjetas de libros
class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final double width;
  final double height;

  const BookCard({
    super.key,
    required this.book,
    this.width = 140,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailScreen(book: book),
        ),
      ),
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: book['cover_url'] != null
                    ? Image.network(
                        book['cover_url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child:
                              Icon(Icons.book, size: 40, color: Colors.white54),
                        ),
                      )
                    : const Center(
                        child:
                            Icon(Icons.book, size: 40, color: Colors.white54),
                      ),
              ),
            ),
            Container(
              height: 60,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      book['title'] ?? 'Sin título',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      book['author'] ?? 'Autor desconocido',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para listas horizontales de contenido (libros y videos)
class HorizontalBookList extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> future;
  final String searchQuery;
  final bool isVideoList;

  const HorizontalBookList({
    super.key,
    required this.future,
    this.searchQuery = '',
    this.isVideoList = false,
  });

  @override
  State<HorizontalBookList> createState() => _HorizontalBookListState();
}

class _HorizontalBookListState extends State<HorizontalBookList> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppWidgets.loadingIndicator;
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AppWidgets.noDataText;
          }

          final items = _filterItems(snapshot.data!);

          // Actualizar botones después de que se construya la lista
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _updateScrollButtons();
            }
          });

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: widget.isVideoList
                        ? VideoCard(video: items[index])
                        : BookCard(book: items[index]),
                  );
                },
              ),
              // Flecha izquierda
              if (_canScrollLeft)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: _scrollLeft,
                      ),
                    ),
                  ),
                ),
              // Flecha derecha
              if (_canScrollRight)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onPressed: _scrollRight,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    if (widget.searchQuery.isEmpty) return items;

    return items.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final author =
          (item['author'] ?? item['channel'] ?? '').toString().toLowerCase();
      final query = widget.searchQuery.toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }
}

// Widget para placeholder de carga
class LoadingPlaceholder extends StatelessWidget {
  final String message;

  const LoadingPlaceholder({
    super.key,
    this.message = 'Cargando contenido...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Servicio para datos optimizado
class DataService {
  static Future<List<Map<String, dynamic>>> getTopBooks() async {
    return BookService().getBooks(limit: 10);
  }

  static Future<List<Map<String, dynamic>>> getRecentBooks() async {
    return BookService().getBooks(limit: 20);
  }

  static Future<List<Map<String, dynamic>>> getRecentVideos() async {
    return VideoService().getVideos();
  }
}

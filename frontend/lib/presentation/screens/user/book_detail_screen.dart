import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_theme.dart';
import '../../../data/services/favorites_service.dart';
import '../../../data/services/stats_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/supabase_auth_service.dart';
import 'flipbook_reader.dart';
import 'dart:ui';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with TickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isLoading = false;
  String _createdByInfo = 'Cargando...';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkFavoriteStatus();
    _incrementViewCount();
    _loadCreatedByInfo();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadCreatedByInfo() async {
    if (widget.book['created_by'] != null) {
      try {
        final userData = await UserService().getUser(widget.book['created_by']);

        setState(() {
          final name = userData?['name'] ?? 'Usuario';
          final role = userData?['role'] ?? 'usuario';
          _createdByInfo = '$name ($role)';
        });
      } catch (e) {
        setState(() {
          _createdByInfo = 'Sistema';
        });
      }
    } else {
      setState(() {
        _createdByInfo = 'Sistema';
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final fav = await FavoritesService().isFavorite(widget.book['id']);
      setState(() {
        _isFavorite = fav;
      });
    } catch (e) {
      print('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (!SupabaseAuthService().isLoggedIn) {
      print('❌ Usuario no autenticado');
      return;
    }

    print('🔄 Toggling favorite for book: ${widget.book['id']}');
    setState(() => _isLoading = true);

    try {
      if (_isFavorite) {
        print('🗑️ Eliminando de favoritos...');
        await FavoritesService().removeFromFavorites(widget.book['id']);
        print('✅ Eliminado de favoritos');
      } else {
        print('❤️ Agregando a favoritos...');
        await FavoritesService().addToFavorites(widget.book['id']);
        print('✅ Agregado a favoritos');
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos'),
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Error en favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      await StatsService().recordBookOpen(widget.book['id']);
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  Future<void> _readBook() async {
    print('📚 === INTENTANDO ABRIR LIBRO ===');
    print('📚 Libro ID: ${widget.book['id']}');
    print('📚 Título: ${widget.book['title']}');
    print('📚 URL del archivo: ${widget.book['file_url']}');
    print('📚 Formato: ${widget.book['format']}');
    print('📚 Es físico: ${widget.book['is_physical']}');

    // Si es un libro físico, mostrar información de ubicación
    if (widget.book['is_physical'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📚 Libro disponible en biblioteca física'),
              if (widget.book['physical_location'] != null)
                Text('📍 Ubicación: ${widget.book['physical_location']}'),
              if (widget.book['codigo_fisico'] != null)
                Text('🏷️ Código: ${widget.book['codigo_fisico']}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (widget.book['file_url'] != null) {
      try {
        print('✅ URL encontrada, navegando al lector...');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlipBookReader(book: widget.book),
          ),
        );
        print('✅ Navegación exitosa');
      } catch (e) {
        print('❌ Error al navegar al lector: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el libro: $e')),
        );
      }
    } else {
      print('❌ No hay URL de archivo disponible');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay archivo disponible para este libro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con efecto glassmorphism
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      height: 80,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.white, size: 24),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Detalles del Libro',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isFavorite
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                  child: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        key: ValueKey(_isFavorite),
                                        color: _isFavorite
                                            ? Colors.red
                                            : Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    onPressed:
                                        _isLoading ? null : _toggleFavorite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Contenido principal con animaciones
              Expanded(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isWideScreen ? 1200 : double.infinity,
                            ),
                            padding: const EdgeInsets.all(32),
                            child: isWideScreen
                                ? _buildWebLayout()
                                : _buildMobileLayout(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Portada (lado izquierdo)
        SizedBox(
          width: 300,
          child: Column(
            children: [
              _buildBookCover(300, 400),
              const SizedBox(height: 24),
              _buildReadButton(),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Información (lado derecho)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookInfo(),
              const SizedBox(height: 32),
              _buildBookDetails(),
              if (widget.book['description'] != null &&
                  widget.book['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildDescription(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildBookCover(200, 280),
        const SizedBox(height: 24),
        _buildBookInfo(),
        const SizedBox(height: 24),
        _buildBookDetails(),
        if (widget.book['description'] != null &&
            widget.book['description'].toString().isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildDescription(),
        ],
        const SizedBox(height: 32),
        _buildReadButton(),
      ],
    );
  }

  Widget _buildBookCover(double width, double height) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Hero(
            tag: 'book-cover-${widget.book['id']}',
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: GlassTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.book['cover_url'] != null
                        ? Image.network(
                            widget.book['cover_url'],
                            fit: BoxFit.cover,
                            width: width,
                            height: height,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultCover(width, height),
                          )
                        : _buildDefaultCover(width, height),
                  ),
                  // Overlay con gradiente sutil
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Brillo en la esquina superior
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultCover(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassTheme.primaryColor.withOpacity(0.6),
            GlassTheme.secondaryColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories,
              size: 80, color: Colors.white.withOpacity(0.8)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.book['title'] ?? 'Sin título',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfo() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título con efecto shimmer
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Colors.white,
                    GlassTheme.primaryColor,
                    Colors.white,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  widget.book['title'] ?? 'Sin título',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Autor con icono
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GlassTheme.primaryColor.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: GlassTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.book['author'] ?? 'Autor desconocido',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Rating visual (si existe)
              if (widget.book['rating'] != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final rating = (widget.book['rating'] ?? 0).toDouble();
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.book['rating']}/5',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookDetails() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, 'Año',
                        widget.book['year']?.toString() ?? 'N/A'),
                    _buildDivider(),
                    _buildInfoRow(
                        Icons.qr_code, 'ISBN', widget.book['isbn'] ?? 'N/A'),
                    _buildDivider(),
                    _buildInfoRow(
                        Icons.person_outline, 'Subido por', _createdByInfo),
                    _buildDivider(),
                    _buildInfoRow(Icons.category_outlined, 'Categoría',
                        widget.book['category'] ?? 'General'),
                    _buildDivider(),
                    _buildInfoRow(Icons.description_outlined, 'Formato',
                        widget.book['format']?.toUpperCase() ?? 'PDF'),
                    if (widget.book['is_physical'] == true) ...[
                      _buildDivider(),
                      _buildPhysicalBookInfo(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description,
                  color: GlassTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Descripción',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.book['description']
                .replaceAll('\n', ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim(),
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GlassTheme.primaryColor,
                  GlassTheme.secondaryColor,
                  Color(0xFF6C63FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: GlassTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _readBook,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                            widget.book['is_physical'] == true
                                ? Icons.library_books
                                : Icons.auto_stories,
                            color: Colors.white,
                            size: 24),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          widget.book['is_physical'] == true
                              ? 'Disponible en\nBiblioteca Física'
                              : 'Leer Libro',
                          style: GoogleFonts.outfit(
                            fontSize:
                                widget.book['is_physical'] == true ? 16 : 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhysicalBookInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.library_books, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Libro Físico Disponible',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.book['codigo_fisico'] != null &&
              widget.book['codigo_fisico'].toString().isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.qr_code_2, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Código:',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.book['codigo_fisico'],
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Ubicación:',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.book['physical_location'] ?? 'No especificada',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  GlassTheme.primaryColor.withOpacity(0.3),
                  GlassTheme.secondaryColor.withOpacity(0.2),
                ],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

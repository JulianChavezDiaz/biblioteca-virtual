import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../data/services/video_service.dart';
import '../../data/services/category_service.dart';
import '../../data/services/supabase_auth_service.dart';
import '../screens/user/mobile_video_player.dart';

class VideoListWidget extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> future;
  final bool canEdit;
  final String userRole;
  final VoidCallback onRefresh;

  const VideoListWidget({
    super.key,
    required this.future,
    required this.canEdit,
    required this.userRole,
    required this.onRefresh,
  });

  @override
  State<VideoListWidget> createState() => _VideoListWidgetState();
}

class _VideoListWidgetState extends State<VideoListWidget> {
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
    if (mounted) {
      setState(() {
        _canScrollLeft = _scrollController.offset > 0;
        _canScrollRight = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    }
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 200,
              child: Center(
                  child: CircularProgressIndicator(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
              height: 200,
              child: Center(
                  child: Text('No hay videos disponibles',
                      style: GoogleFonts.outfit(color: Colors.white70))));
        }

        // Actualizar botones después de que se construya la lista
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _updateScrollButtons();
          }
        });

        return _buildVideoList(snapshot.data!, context);
      },
    );
  }

  Widget _buildVideoList(
      List<Map<String, dynamic>> videos, BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('🎬 DEBUG: Tapping video: ${video['title']}');
                        print('🎬 DEBUG: Video data: $video');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MobileVideoPlayer(video: video),
                          ),
                        );
                      },
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: double.infinity,
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
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: video['thumbnail_url'] != null
                                    ? Image.network(
                                        video['thumbnail_url'],
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade800,
                                          child: const Icon(Icons.video_library,
                                              size: 40, color: Colors.white54),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.video_library,
                                            size: 40, color: Colors.white54),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        video['title'] ?? 'Sin título',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        video['category'] ?? 'Sin categoría',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (video['views'] != null)
                                      Flexible(
                                        child: Text(
                                          '${video['views']} vistas',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            color: Colors.white54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.canEdit &&
                        (widget.userRole == 'bibliotecario' ||
                            widget.userRole == 'admin' ||
                            (widget.userRole == 'profesor' &&
                                video['created_by'] ==
                                    SupabaseAuthService().currentUser?.id)))
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.more_vert,
                                color: Colors.white, size: 16),
                          ),
                          onSelected: (value) =>
                              _handleMenuAction(value, video, context),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            if (widget.userRole == 'admin' ||
                                (widget.userRole == 'profesor' &&
                                    video['created_by'] ==
                                        SupabaseAuthService().currentUser?.id))
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
      ),
    );
  }

  void _handleMenuAction(
      String action, Map<String, dynamic> video, BuildContext context) {
    print('🎬 DEBUG: Action: $action, UserRole: ${widget.userRole}');
    print('🎬 DEBUG: Video created_by: ${video['created_by']}');
    print('🎬 DEBUG: Current user: ${SupabaseAuthService().currentUser?.id}');

    if (action == 'edit') {
      print('🎬 DEBUG: Calling _showEditDialog');
      _showEditDialog(context, video);
    } else if (action == 'delete' &&
        (widget.userRole == 'admin' ||
            (widget.userRole == 'profesor' &&
                video['created_by'] ==
                    SupabaseAuthService().currentUser?.id))) {
      print('🎬 DEBUG: Calling _showDeleteDialog');
      _showDeleteDialog(context, video);
    } else {
      print('🎬 DEBUG: Delete condition failed');
    }
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> video) {
    final titleController = TextEditingController(text: video['title'] ?? '');
    final urlController = TextEditingController(text: video['video_id'] ?? '');
    final descriptionController =
        TextEditingController(text: video['description'] ?? '');
    final thumbnailController =
        TextEditingController(text: video['thumbnail_url'] ?? '');
    String selectedCategory = video['category'] ?? 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Editar Video',
              style: GoogleFonts.outfit(color: Colors.white)),
          content: SizedBox(
            width: 500,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Título',
                      labelStyle: GoogleFonts.outfit(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'URL del Video',
                      labelStyle: GoogleFonts.outfit(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: thumbnailController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'URL de la portada (opcional)',
                      labelStyle: GoogleFonts.outfit(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: GoogleFonts.outfit(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: CategoryService().getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(
                            color: Colors.white);
                      }
                      final categoryNames = snapshot.data!
                          .map((category) => category['name']?.toString())
                          .whereType<String>()
                          .where((name) => name.isNotEmpty)
                          .toSet()
                          .toList();
                      if (selectedCategory.isEmpty) {
                        selectedCategory = 'General';
                      }
                      if (!categoryNames.contains(selectedCategory)) {
                        categoryNames.insert(0, selectedCategory);
                      }
                      return DropdownButtonFormField<String>(
                        value: selectedCategory,
                        style: GoogleFonts.outfit(color: Colors.white),
                        dropdownColor: const Color(0xFF1E293B),
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          labelStyle: GoogleFonts.outfit(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange)),
                        ),
                        items: categoryNames
                            .map<DropdownMenuItem<String>>(
                                (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedCategory = value!),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: GoogleFonts.outfit(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (titleController.text.trim().isEmpty ||
                      urlController.text.trim().isEmpty) {
                    throw Exception('Título y URL del video son obligatorios');
                  }

                  final updatedVideo =
                      await VideoService().updateVideo(video['id'], {
                    'title': titleController.text.trim(),
                    'video_id': urlController.text.trim(),
                    'description': descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    'category': selectedCategory.trim(),
                    'thumbnail_url': thumbnailController.text.isEmpty
                        ? null
                        : thumbnailController.text,
                  });
                  video
                    ..clear()
                    ..addAll(updatedVideo);

                  Navigator.pop(context);
                  if (!mounted) return;
                  widget.onRefresh();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                        content: Text('Video actualizado correctamente',
                            style: GoogleFonts.outfit()),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                        content: Text('Error al actualizar: $e',
                            style: GoogleFonts.outfit()),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('Guardar',
                  style: GoogleFonts.outfit(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> video) {
    print('🎬 DEBUG: Showing delete dialog for video: ${video['title']}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Eliminar video',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('¿Seguro que quieres eliminar este video?',
            style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              print('🎬 DEBUG: Cancel button pressed');
              Navigator.pop(context);
            },
            child: Text('Cancelar',
                style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              print('🎬 DEBUG: Delete button pressed');
              Navigator.pop(context);
              try {
                print(
                    '🎬 DEBUG: Attempting to delete video with ID: ${video['id']}');
                await VideoService().deleteVideo(video['id']);
                print('🎬 DEBUG: Video deleted successfully');
                print('🎬 DEBUG: Calling onRefresh()');
                widget.onRefresh();
                print('🎬 DEBUG: onRefresh() called');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Video eliminado correctamente',
                            style: GoogleFonts.outfit()),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                print('🎬 DEBUG: Error deleting video: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al eliminar: $e',
                            style: GoogleFonts.outfit()),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child:
                Text('Eliminar', style: GoogleFonts.outfit(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

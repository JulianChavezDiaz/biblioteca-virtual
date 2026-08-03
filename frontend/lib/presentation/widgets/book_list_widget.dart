import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../data/services/book_service.dart';
import '../../data/services/category_service.dart';
import '../../data/services/upload_service.dart';
import '../../data/services/supabase_auth_service.dart';
import '../screens/user/book_detail_screen.dart';

class BookListWidget extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> future;
  final bool canEdit;
  final String userRole;
  final VoidCallback onRefresh;

  const BookListWidget({
    super.key,
    required this.future,
    required this.canEdit,
    required this.userRole,
    required this.onRefresh,
  });

  @override
  State<BookListWidget> createState() => _BookListWidgetState();
}

class _BookListWidgetState extends State<BookListWidget> {
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
                  child: Text('No hay libros disponibles',
                      style: GoogleFonts.outfit(color: Colors.white70))));
        }

        // Actualizar botones después de que se construya la lista
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _updateScrollButtons();
          }
        });

        return _buildBookList(snapshot.data!, context);
      },
    );
  }

  Widget _buildBookList(
      List<Map<String, dynamic>> books, BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
                        ),
                      ),
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
                            SizedBox(
                              height: 120,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: book['cover_url'] != null
                                    ? Image.network(
                                        book['cover_url'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                                child: Icon(Icons.book,
                                                    size: 40,
                                                    color: Colors.white54)),
                                      )
                                    : const Center(
                                        child: Icon(Icons.book,
                                            size: 40, color: Colors.white54)),
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
                    ),
                    if (widget.canEdit &&
                        (widget.userRole == 'bibliotecario' ||
                            widget.userRole == 'admin' ||
                            widget.userRole == 'administrador' ||
                            (widget.userRole == 'profesor' &&
                                book['created_by'] ==
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
                              _handleMenuAction(value, book, context),
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
                                widget.userRole == 'administrador' ||
                                (widget.userRole == 'profesor' &&
                                    book['created_by'] ==
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
      String action, Map<String, dynamic> book, BuildContext context) {
    if (action == 'edit') {
      _showEditDialog(context, book);
    } else if (action == 'delete' &&
        (widget.userRole == 'admin' ||
            widget.userRole == 'administrador' ||
            (widget.userRole == 'profesor' &&
                book['created_by'] == SupabaseAuthService().currentUser?.id))) {
      _showDeleteDialog(context, book);
    }
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> book) {
    final titleController = TextEditingController(text: book['title'] ?? '');
    final authorController = TextEditingController(text: book['author'] ?? '');
    final descriptionController =
        TextEditingController(text: book['description'] ?? '');
    final fileUrlController =
        TextEditingController(text: book['file_url'] ?? '');
    final coverUrlController =
        TextEditingController(text: book['cover_url'] ?? '');
    final isbnController = TextEditingController(text: book['isbn'] ?? '');
    final yearController =
        TextEditingController(text: book['year']?.toString() ?? '');
    final locationController =
        TextEditingController(text: book['physical_location'] ?? '');
    final codigoFisicoController =
        TextEditingController(text: book['codigo_fisico'] ?? '');

    String selectedFormat = book['format'] ?? 'pdf';
    String selectedCategory = book['category'] ?? 'General';
    bool isPhysical = book['is_physical'] ?? false;
    bool useFileUpload = false;
    bool useCoverUpload = false;
    Uint8List? selectedFile;
    String? selectedFileName;
    PlatformFile? selectedCover;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Editar Libro',
              style: GoogleFonts.outfit(color: Colors.white)),
          content: SizedBox(
            width: 500,
            height: 600,
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
                    controller: authorController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Autor',
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
                  // Sección de archivo del libro
                  if (!isPhysical)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Archivo del libro',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text('URL del archivo',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white70, fontSize: 12)),
                                value: false,
                                groupValue: useFileUpload,
                                onChanged: (value) => setState(() {
                                  useFileUpload = value!;
                                  selectedFile = null;
                                  selectedFileName = null;
                                }),
                                activeColor: Colors.orange,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: Text('Subir archivo',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white70, fontSize: 12)),
                                value: true,
                                groupValue: useFileUpload,
                                onChanged: (value) => setState(() {
                                  useFileUpload = value!;
                                  fileUrlController.clear();
                                }),
                                activeColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        if (!useFileUpload)
                          TextField(
                            controller: fileUrlController,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'URL del archivo',
                              labelStyle:
                                  GoogleFonts.outfit(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange)),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: selectedFile != null
                                      ? Colors.orange
                                      : Colors.white.withOpacity(0.3)),
                            ),
                            child: selectedFile == null
                                ? Column(
                                    children: [
                                      const Icon(Icons.cloud_upload,
                                          size: 40, color: Colors.orange),
                                      const SizedBox(height: 8),
                                      Text('Seleccionar archivo PDF/EPUB',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white)),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: [
                                                'pdf',
                                                'epub'
                                              ],
                                              withData: true,
                                            );
                                            if (result != null &&
                                                result.files.single.bytes !=
                                                    null) {
                                              setState(() {
                                                selectedFile =
                                                    result.files.single.bytes!;
                                                selectedFileName =
                                                    result.files.single.name;
                                              });
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text('Error: $e')),
                                            );
                                          }
                                        },
                                        child: const Text('Seleccionar'),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 40, color: Colors.green),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Archivo: ${selectedFileName ?? "archivo.pdf"}',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white)),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => setState(() {
                                          selectedFile = null;
                                          selectedFileName = null;
                                        }),
                                        child: const Text('Quitar'),
                                      ),
                                    ],
                                  ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Sección de portada
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Portada del libro',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('URL de portada',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white70, fontSize: 12)),
                              value: false,
                              groupValue: useCoverUpload,
                              onChanged: (value) => setState(() {
                                useCoverUpload = value!;
                                selectedCover = null;
                              }),
                              activeColor: Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text('Subir imagen',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white70, fontSize: 12)),
                              value: true,
                              groupValue: useCoverUpload,
                              onChanged: (value) => setState(() {
                                useCoverUpload = value!;
                                coverUrlController.clear();
                              }),
                              activeColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      if (!useCoverUpload)
                        TextField(
                          controller: coverUrlController,
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'URL de la portada',
                            labelStyle:
                                GoogleFonts.outfit(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3))),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange)),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: selectedCover != null
                                    ? Colors.orange
                                    : Colors.white.withOpacity(0.3)),
                          ),
                          child: selectedCover == null
                              ? Column(
                                  children: [
                                    const Icon(Icons.image,
                                        size: 40, color: Colors.orange),
                                    const SizedBox(height: 8),
                                    Text('Seleccionar imagen',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            type: FileType.image,
                                            withData: true,
                                          );
                                          if (result != null &&
                                              result.files.single.bytes !=
                                                  null) {
                                            setState(() {
                                              selectedCover =
                                                  result.files.single;
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text('Error: $e')),
                                          );
                                        }
                                      },
                                      child: const Text('Seleccionar'),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 40, color: Colors.green),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Imagen: ${selectedCover?.name ?? "imagen.jpg"}',
                                        style: GoogleFonts.outfit(
                                            color: Colors.white)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          setState(() => selectedCover = null),
                                      child: const Text('Quitar'),
                                    ),
                                  ],
                                ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: isbnController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'ISBN',
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
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Año',
                      labelStyle: GoogleFonts.outfit(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedFormat,
                    style: GoogleFonts.outfit(color: Colors.white),
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: InputDecoration(
                      labelText: 'Formato',
                      labelStyle: GoogleFonts.outfit(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    items: ['pdf', 'epub']
                        .map((format) => DropdownMenuItem(
                              value: format,
                              child: Text(format.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedFormat = value!),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: CategoryService().getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(
                            color: Colors.white);
                      }
                      final categories = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: categories
                                .any((cat) => cat['name'] == selectedCategory)
                            ? selectedCategory
                            : categories.first['name'],
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
                        items: categories
                            .map<DropdownMenuItem<String>>(
                                (category) => DropdownMenuItem(
                                      value: category['name'],
                                      child: Text(category['name']),
                                    ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedCategory = value!),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Libro Físico',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        CheckboxListTile(
                          title: Text('¿Es un libro físico?',
                              style: GoogleFonts.outfit(color: Colors.white70)),
                          value: isPhysical,
                          onChanged: (value) =>
                              setState(() => isPhysical = value ?? false),
                          activeColor: Colors.orange,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (isPhysical)
                          TextField(
                            controller: codigoFisicoController,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Código Físico',
                              labelStyle:
                                  GoogleFonts.outfit(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange)),
                            ),
                          ),
                        if (isPhysical) const SizedBox(height: 16),
                        if (isPhysical)
                          TextField(
                            controller: locationController,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Ubicación en biblioteca',
                              labelStyle:
                                  GoogleFonts.outfit(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange)),
                            ),
                          ),
                      ],
                    ),
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
                  print('📝 === ACTUALIZANDO LIBRO ===');
                  print('📝 Libro ID: ${book['id']}');
                  print('📝 Título: ${titleController.text}');
                  print('📝 Usar subida de portada: $useCoverUpload');
                  print('📝 Portada seleccionada: ${selectedCover?.name}');
                  print('📝 URL de portada: ${coverUrlController.text}');

                  String? finalCoverUrl;

                  // Subir portada si se seleccionó archivo
                  if (useCoverUpload && selectedCover != null) {
                    print('📝 Subiendo nueva portada...');
                    try {
                      final coverName =
                          '${DateTime.now().millisecondsSinceEpoch}_cover_${titleController.text.replaceAll(' ', '_')}.jpg';

                      if (selectedCover!.bytes != null) {
                        finalCoverUrl = await UploadService()
                            .upload(selectedCover!.bytes!, coverName);

                        print('📝 Nueva URL de portada: $finalCoverUrl');
                      }
                    } catch (storageError) {
                      print('❌ Error subiendo portada: $storageError');
                    }
                  } else if (!useCoverUpload &&
                      coverUrlController.text.isNotEmpty) {
                    finalCoverUrl = coverUrlController.text;
                    print('📝 Usando URL de portada: $finalCoverUrl');
                  } else {
                    finalCoverUrl = book['cover_url']; // Mantener la actual
                    print('📝 Manteniendo portada actual: $finalCoverUrl');
                  }

                  final updateData = {
                    'title': titleController.text,
                    'author': authorController.text,
                    'description': descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    'file_url': fileUrlController.text,
                    'cover_url': finalCoverUrl,
                    'isbn': isbnController.text.isEmpty
                        ? null
                        : isbnController.text,
                    'year': yearController.text.isEmpty
                        ? null
                        : int.tryParse(yearController.text),
                    'format': selectedFormat,
                    'category': selectedCategory,
                    'is_physical': isPhysical,
                    'physical_location':
                        isPhysical ? locationController.text : null,
                    'codigo_fisico':
                        isPhysical ? codigoFisicoController.text : null,
                  };

                  print('📝 Datos a actualizar: $updateData');

                  await BookService().updateBook(book['id'], updateData);

                  print('✅ Libro actualizado');

                  Navigator.pop(context);
                  print('🔄 Llamando onRefresh...');
                  // Forzar limpieza de caché y refresh
                  Future.microtask(() {
                    widget.onRefresh();
                    // Segundo refresh después de un delay
                    Future.delayed(const Duration(milliseconds: 500), () {
                      widget.onRefresh();
                    });
                  });
                  print('🔄 onRefresh completado');

                  // Forzar rebuild del widget padre
                  if (context.mounted) {
                    print('🔄 Forzando rebuild...');
                    // Limpiar caché si existe
                    try {
                      print('🗑️ Limpiando caché...');
                      // Simplemente hacer refresh sin limpiar caché
                      await Future.delayed(const Duration(milliseconds: 100));
                      widget.onRefresh();
                    } catch (e) {
                      print('Error en segundo refresh: $e');
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Libro actualizado correctamente',
                            style: GoogleFonts.outfit()),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  print('❌ Error actualizando libro: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al actualizar: $e',
                              style: GoogleFonts.outfit()),
                          backgroundColor: Colors.red),
                    );
                  }
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

  Widget _buildFileSection(
      TextEditingController fileUrlController,
      bool useFileUpload,
      Uint8List? selectedFile,
      String? selectedFileName,
      StateSetter setState,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Archivo del libro',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text('URL del archivo',
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 12)),
                value: false,
                groupValue: useFileUpload,
                onChanged: (value) => setState(() {
                  useFileUpload = value!;
                  selectedFile = null;
                  selectedFileName = null;
                }),
                activeColor: Colors.orange,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('Subir archivo',
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 12)),
                value: true,
                groupValue: useFileUpload,
                onChanged: (value) => setState(() {
                  useFileUpload = value!;
                  fileUrlController.clear();
                }),
                activeColor: Colors.orange,
              ),
            ),
          ],
        ),
        if (!useFileUpload)
          TextField(
            controller: fileUrlController,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'URL del archivo',
              labelStyle: GoogleFonts.outfit(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selectedFile != null
                      ? Colors.orange
                      : Colors.white.withOpacity(0.3)),
            ),
            child: selectedFile == null
                ? Column(
                    children: [
                      const Icon(Icons.cloud_upload,
                          size: 40, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text('Seleccionar archivo PDF/EPUB',
                          style: GoogleFonts.outfit(color: Colors.white)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickFile(setState, context),
                        child: const Text('Seleccionar'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 40, color: Colors.green),
                      const SizedBox(height: 8),
                      Text('Archivo: ${selectedFileName ?? "archivo.pdf"}',
                          style: GoogleFonts.outfit(color: Colors.white)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          selectedFile = null;
                          selectedFileName = null;
                        }),
                        child: const Text('Quitar'),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }

  Widget _buildCoverSection(
      TextEditingController coverUrlController,
      bool useCoverUpload,
      PlatformFile? selectedCover,
      StateSetter setState,
      BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portada del libro',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text('URL de portada',
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 12)),
                value: false,
                groupValue: useCoverUpload,
                onChanged: (value) => setState(() {
                  useCoverUpload = value!;
                  selectedCover = null;
                }),
                activeColor: Colors.orange,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text('Subir imagen',
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 12)),
                value: true,
                groupValue: useCoverUpload,
                onChanged: (value) => setState(() {
                  useCoverUpload = value!;
                  coverUrlController.clear();
                }),
                activeColor: Colors.orange,
              ),
            ),
          ],
        ),
        if (!useCoverUpload)
          TextField(
            controller: coverUrlController,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'URL de la portada',
              labelStyle: GoogleFonts.outfit(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selectedCover != null
                      ? Colors.orange
                      : Colors.white.withOpacity(0.3)),
            ),
            child: selectedCover == null
                ? Column(
                    children: [
                      const Icon(Icons.image, size: 40, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text('Seleccionar imagen',
                          style: GoogleFonts.outfit(color: Colors.white)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickCoverImage(setState, context),
                        child: const Text('Seleccionar'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 40, color: Colors.green),
                      const SizedBox(height: 8),
                      Text('Imagen: ${selectedCover?.name ?? "imagen.jpg"}',
                          style: GoogleFonts.outfit(color: Colors.white)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() => selectedCover = null),
                        child: const Text('Quitar'),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }

  Future<void> _pickFile(StateSetter setState, BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          // Variables locales - necesitan ser manejadas en el contexto del diálogo
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _pickCoverImage(
      StateSetter setState, BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          // Variables locales - necesitan ser manejadas en el contexto del diálogo
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Eliminar libro',
            style: GoogleFonts.outfit(color: Colors.white)),
        content: Text('¿Seguro que quieres eliminar este libro?',
            style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                print('🗑️ === INTENTANDO ELIMINAR LIBRO ===');
                print('🗑️ Libro ID: ${book['id']}');
                print('🗑️ Título: ${book['title']}');
                print(
                    '🗑️ Usuario actual: ${SupabaseAuthService().currentUser?.id}');
                print('🗑️ Rol del usuario: ${widget.userRole}');
                print('🗑️ Creado por: ${book['created_by']}');

                // Hacer soft delete del libro (marcar como eliminado)
                print('🗑️ Marcando libro como eliminado (soft delete)...');
                await BookService().deleteBook(book['id']);

                print('✅ Libro eliminado');

                widget.onRefresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Libro eliminado correctamente',
                            style: GoogleFonts.outfit()),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                print('❌ Error eliminando libro: $e');
                print('❌ Tipo de error: ${e.runtimeType}');
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

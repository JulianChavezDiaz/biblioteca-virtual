import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../core/theme/app_colors.dart';
import '../../core/theme/optimized_theme.dart';
import '../../data/services/book_service.dart';
import '../../data/services/video_service.dart';
import '../../data/services/category_service.dart';
import '../../data/services/upload_service.dart';

class OptimizedModals {
  // Modal para reproducir videos
  static void showVideoModal(
      BuildContext context, String videoUrl, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              title,
              style: OptimizedTheme.heading3,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _VideoPlayer(videoUrl: videoUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modal para leer PDFs
  static void showPdfModal(BuildContext context, String pdfUrl, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.yaviracBlueDark,
            title: Text(
              title,
              style: OptimizedTheme.heading3,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                onPressed: () => _openInNewTab(pdfUrl),
              ),
            ],
          ),
          body: _PdfViewer(pdfUrl: pdfUrl),
        ),
      ),
    );
  }

  // Modal para agregar libro digital
  static void showAddBookModal(BuildContext context, {Function()? onSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.yaviracBlueDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.yaviracOrange.withOpacity(0.3)),
          ),
          child: _AddBookForm(onSuccess: onSuccess, isPhysicalOnly: false),
        ),
      ),
    );
  }

  // Modal para agregar libro físico
  static void showAddPhysicalBookModal(BuildContext context,
      {Function()? onSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.yaviracBlueDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.yaviracOrange.withOpacity(0.3)),
          ),
          child: _AddBookForm(onSuccess: onSuccess, isPhysicalOnly: true),
        ),
      ),
    );
  }

  // Modal para agregar video
  static void showAddVideoModal(BuildContext context, {Function()? onSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: AppColors.yaviracBlueDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.yaviracOrange.withOpacity(0.3)),
          ),
          child: _AddVideoForm(onSuccess: onSuccess),
        ),
      ),
    );
  }

  // Modal de confirmación
  static void showConfirmModal(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.yaviracBlueDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: OptimizedTheme.heading3,
        ),
        content: Text(
          message,
          style: OptimizedTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText, style: OptimizedTheme.bodyTextSmall),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yaviracOrange),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmText, style: OptimizedTheme.bodyText),
          ),
        ],
      ),
    );
  }

  static void _openInNewTab(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

// Widget para reproductor de video optimizado
class _VideoPlayer extends StatelessWidget {
  final String videoUrl;

  const _VideoPlayer({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline,
                size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Reproducir Video',
              style: OptimizedTheme.heading3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openInNewTab(videoUrl),
              child: const Text('Abrir Video'),
            ),
          ],
        ),
      ),
    );
  }

  void _openInNewTab(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

// Widget para visor de PDF optimizado
class _PdfViewer extends StatelessWidget {
  final String pdfUrl;

  const _PdfViewer({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Documento PDF',
              style: OptimizedTheme.heading3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openInNewTab(pdfUrl),
              child: const Text('Abrir PDF'),
            ),
          ],
        ),
      ),
    );
  }

  void _openInNewTab(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

// Formulario optimizado para agregar libros
class _AddBookForm extends StatefulWidget {
  final Function()? onSuccess;
  final bool isPhysicalOnly;

  const _AddBookForm({this.onSuccess, this.isPhysicalOnly = false});

  @override
  State<_AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<_AddBookForm> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();

  String _selectedFormat = 'pdf';
  String? _selectedCategory;
  String? _selectedSubcategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _loadingCategories = true;
  bool _useFileUpload = false;
  Uint8List? _selectedFile;
  String? _selectedFileName;
  bool _uploadingFile = false;
  bool _isPhysical = false;
  PlatformFile? _selectedCover;
  final _locationController = TextEditingController();
  final _codigoFisicoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await CategoryService().getCategories();

      setState(() {
        _categories = response;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first['name'];
        }
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isPhysicalOnly ? 'Agregar Libro Físico' : 'Agregar Libro',
          style: OptimizedTheme.heading2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child:
                          _buildInput(_titleController, 'Título', Icons.title)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildInput(
                          _authorController, 'Autor', Icons.person)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput(
                  _descriptionController, 'Descripción', Icons.description,
                  maxLines: 3),
              const SizedBox(height: 16),
              // Solo mostrar sección de archivos si NO es libro físico
              if (!widget.isPhysicalOnly) _buildFileUploadSection(),
              if (!widget.isPhysicalOnly) const SizedBox(height: 16),
              _buildCoverSection(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child:
                          _buildInput(_isbnController, 'ISBN', Icons.qr_code)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildInput(
                          _yearController, 'Año', Icons.calendar_today,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFormatDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              _buildPhysicalBookSection(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown()),
                ],
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: OptimizedTheme.bodyText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: OptimizedTheme.bodyTextSmall,
        prefixIcon: Icon(icon, color: AppColors.yaviracOrange),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yaviracOrange),
        ),
      ),
    );
  }

  Widget _buildFormatDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedFormat,
      decoration: InputDecoration(
        labelText: 'Formato',
        labelStyle: OptimizedTheme.bodyTextSmall,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.yaviracBlueDark,
      style: OptimizedTheme.bodyText,
      items: ['pdf', 'epub']
          .map<DropdownMenuItem<String>>((format) => DropdownMenuItem<String>(
                value: format,
                child: Text(format.toUpperCase()),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedFormat = value!),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_loadingCategories) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No hay categorías disponibles',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        labelStyle: OptimizedTheme.bodyTextSmall,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.yaviracBlueDark,
      style: OptimizedTheme.bodyText,
      items: _categories
          .map<DropdownMenuItem<String>>((category) => DropdownMenuItem<String>(
                value: category['name'] as String,
                child: Text(category['name'] as String),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yaviracOrange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _submitBook,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Agregar Libro',
                style: OptimizedTheme.bodyText
                    .copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _submitBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y autor')),
      );
      return;
    }

    if (!widget.isPhysicalOnly &&
        !_useFileUpload &&
        _fileUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa URL del archivo')),
      );
      return;
    }

    if (!widget.isPhysicalOnly && _useFileUpload && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un archivo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? fileUrl;
      String? coverUrl;

      // Subir portada si es local
      if (_selectedCover != null) {
        try {
          final coverName =
              '${DateTime.now().millisecondsSinceEpoch}_cover_${_titleController.text.replaceAll(' ', '_')}.jpg';

          if (_selectedCover!.bytes != null) {
            coverUrl =
                await UploadService().upload(_selectedCover!.bytes!, coverName);
          }
        } catch (storageError) {
          print('Error subiendo portada: $storageError');
        }
      } else if (_coverUrlController.text.isNotEmpty) {
        coverUrl = _coverUrlController.text;
      }

      if (!widget.isPhysicalOnly) {
        if (_useFileUpload) {
          fileUrl = await _uploadFile();
          if (fileUrl == null) {
            setState(() => _isLoading = false);
            return;
          }
        } else {
          fileUrl = _fileUrlController.text;
        }
      }

      await BookService().createBook({
        'title': _titleController.text,
        'author': _authorController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'file_url': (widget.isPhysicalOnly || _isPhysical) ? null : fileUrl,
        'cover_url': coverUrl,
        'isbn': _isbnController.text.isEmpty ? null : _isbnController.text,
        'year': _yearController.text.isEmpty
            ? null
            : int.tryParse(_yearController.text),
        'format':
            (widget.isPhysicalOnly || _isPhysical) ? 'pdf' : _selectedFormat,
        'category': _selectedCategory,
        'published_date': DateTime.now().toIso8601String().split('T')[0],
        'is_physical': widget.isPhysicalOnly || _isPhysical,
        'physical_location': (widget.isPhysicalOnly || _isPhysical)
            ? _locationController.text
            : null,
        'codigo_fisico': (widget.isPhysicalOnly || _isPhysical)
            ? _codigoFisicoController.text
            : null,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro agregado exitosamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('URL del archivo',
                    style: OptimizedTheme.bodyTextSmall),
                value: false,
                groupValue: _useFileUpload,
                onChanged: (value) => setState(() {
                  _useFileUpload = value!;
                  _selectedFile = null;
                  _selectedFileName = null;
                }),
                activeColor: AppColors.yaviracOrange,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Subir archivo',
                    style: OptimizedTheme.bodyTextSmall),
                value: true,
                groupValue: _useFileUpload,
                onChanged: (value) => setState(() {
                  _useFileUpload = value!;
                  _fileUrlController.clear();
                }),
                activeColor: AppColors.yaviracOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!_useFileUpload)
          _buildInput(
              _fileUrlController, 'URL del archivo (PDF/EPUB)', Icons.link)
        else
          _buildFilePickerSection(),
      ],
    );
  }

  Widget _buildFilePickerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedFile != null
              ? AppColors.yaviracOrange
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          if (_selectedFile == null) ...[
            const Icon(Icons.cloud_upload,
                size: 48, color: AppColors.yaviracOrange),
            const SizedBox(height: 16),
            const Text(
              'Seleccionar archivo PDF o EPUB',
              style: OptimizedTheme.bodyText,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('Seleccionar Archivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yaviracOrange,
              ),
            ),
          ] else ...[
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Archivo seleccionado:',
              style: OptimizedTheme.bodyTextSmall,
            ),
            Text(
              _selectedFileName ?? 'archivo.pdf',
              style:
                  OptimizedTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Cambiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yaviracOrange,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _selectedFile = null;
                    _selectedFileName = null;
                  }),
                  icon: const Icon(Icons.delete),
                  label: const Text('Quitar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedFile = result.files.single.bytes!;
          _selectedFileName = result.files.single.name;
          if (_selectedFileName!.toLowerCase().endsWith('.epub')) {
            _selectedFormat = 'epub';
          } else {
            _selectedFormat = 'pdf';
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar archivo: $e')),
      );
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null || _selectedFileName == null) return null;

    setState(() => _uploadingFile = true);

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_selectedFileName';

      final publicUrl = await UploadService().upload(_selectedFile!, fileName);

      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivo: $e')),
      );
      return null;
    } finally {
      setState(() => _uploadingFile = false);
    }
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portada del libro',
          style: OptimizedTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('URL de portada',
                    style: OptimizedTheme.bodyTextSmall),
                value: false,
                groupValue: _selectedCover != null,
                onChanged: (value) => setState(() {
                  _selectedCover = null;
                }),
                activeColor: AppColors.yaviracOrange,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Subir imagen',
                    style: OptimizedTheme.bodyTextSmall),
                value: true,
                groupValue: _selectedCover != null,
                onChanged: (value) => _pickCoverImage(),
                activeColor: AppColors.yaviracOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedCover == null)
          _buildInput(
              _coverUrlController, 'URL de la portada (opcional)', Icons.image)
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.yaviracOrange),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Imagen seleccionada: ${_selectedCover?.name ?? "imagen.jpg"}',
                    style: OptimizedTheme.bodyTextSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedCover = null),
                  child:
                      const Text('Quitar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickCoverImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedCover = result.files.single;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Widget _buildPhysicalBookSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.library_books, color: AppColors.yaviracOrange),
              const SizedBox(width: 8),
              Text('Libro Físico',
                  style: OptimizedTheme.bodyText
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('¿Es un libro físico disponible en biblioteca?',
                style: OptimizedTheme.bodyTextSmall),
            value: _isPhysical,
            onChanged: (value) => setState(() => _isPhysical = value ?? false),
            activeColor: AppColors.yaviracOrange,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_isPhysical) ...[
            const SizedBox(height: 16),
            _buildInput(
                _codigoFisicoController, 'Código Físico', Icons.qr_code_2),
            const SizedBox(height: 16),
            _buildInput(_locationController, 'Ubicación en biblioteca',
                Icons.location_on),
          ],
        ],
      ),
    );
  }
}

// Formulario optimizado para agregar videos
class _AddVideoForm extends StatefulWidget {
  final Function()? onSuccess;

  const _AddVideoForm({this.onSuccess});

  @override
  State<_AddVideoForm> createState() => _AddVideoFormState();
}

class _AddVideoFormState extends State<_AddVideoForm> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();

  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await CategoryService().getCategories();

      setState(() {
        _categories = response;
        _selectedCategory =
            _categories.isNotEmpty ? _categories.first['name'] : null;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Agregar Video',
          style: OptimizedTheme.heading2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInput(
                  _titleController, 'Título del Video', Icons.video_library),
              const SizedBox(height: 16),
              _buildInput(_urlController, 'URL del Video', Icons.link),
              const SizedBox(height: 16),
              _buildInput(_thumbnailController, 'URL de la portada (opcional)',
                  Icons.image),
              const SizedBox(height: 16),
              _buildInput(
                  _descriptionController, 'Descripción', Icons.description,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: OptimizedTheme.bodyText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: OptimizedTheme.bodyTextSmall,
        prefixIcon: Icon(icon, color: AppColors.yaviracOrange),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yaviracOrange),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yaviracOrange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _submitVideo,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Agregar Video',
                style: OptimizedTheme.bodyText
                    .copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_loadingCategories) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No hay categorías disponibles',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        labelStyle: OptimizedTheme.bodyTextSmall,
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.yaviracBlueDark,
      style: OptimizedTheme.bodyText,
      items: _categories
          .map<DropdownMenuItem<String>>((category) => DropdownMenuItem<String>(
                value: category['name'] as String,
                child: Text(category['name'] as String),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Future<void> _submitVideo() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await VideoService().createVideo({
        'title': _titleController.text,
        'video_id': _urlController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'category': _selectedCategory,
        'thumbnail_url': _thumbnailController.text.isEmpty
            ? null
            : _thumbnailController.text,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video agregado exitosamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }
}

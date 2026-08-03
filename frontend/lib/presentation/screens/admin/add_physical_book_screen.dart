import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../theme/glass_theme.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/services/book_service.dart';
import '../../../data/services/upload_service.dart';

class AddPhysicalBookScreen extends StatefulWidget {
  const AddPhysicalBookScreen({super.key});

  @override
  State<AddPhysicalBookScreen> createState() => _AddPhysicalBookScreenState();
}

class _AddPhysicalBookScreenState extends State<AddPhysicalBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  final _codigoFisicoController = TextEditingController();

  PlatformFile? _selectedCover;

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

  Future<void> _pickCover() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedCover = result.files.single;
        _coverUrlController.text =
            'Imagen seleccionada: ${_selectedCover!.name}';
      });
    }
  }

  Future<void> _addPhysicalBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y autor')),
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La ubicación es obligatoria para libros físicos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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
      } else if (_coverUrlController.text.isNotEmpty &&
          !_coverUrlController.text.contains('seleccionada')) {
        coverUrl = _coverUrlController.text;
      }
      await BookService().createBook({
        'title': _titleController.text,
        'author': _authorController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'file_url': 'LIBRO_FISICO', // Placeholder para libro físico
        'cover_url': coverUrl, // Con portada
        'isbn': _isbnController.text.isEmpty ? null : _isbnController.text,
        'year': _yearController.text.isEmpty
            ? null
            : int.tryParse(_yearController.text),
        'format': 'fisico',
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'categories': [_selectedCategory],
        'published_date': DateTime.now().toIso8601String().split('T')[0],
        'is_physical': true,
        'physical_location': _locationController.text,
        'codigo_fisico': _codigoFisicoController.text.isEmpty
            ? null
            : _codigoFisicoController.text,
      });

      if (mounted) {
        CacheService.remove('recent_books_stats');
        CacheService.remove('top_books_stats');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Libro físico agregado exitosamente',
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
                    'AGREGAR LIBRO FÍSICO',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Registra libros de la biblioteca física',
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
              child:
                  const Icon(Icons.location_on, color: Colors.white, size: 30),
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
            _buildSectionTitle('Información del Libro', Icons.book),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child:
                        _buildInput(_titleController, 'Título', Icons.title)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildInput(
                        _authorController, 'Autor', Icons.person_outline)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput(_descriptionController, 'Descripción',
                Icons.description_outlined,
                maxLines: 3),
            const SizedBox(height: 30),
            _buildSectionTitle('Portada del Libro', Icons.image),
            const SizedBox(height: 20),
            _buildCoverSection(),
            const SizedBox(height: 30),
            _buildSectionTitle('Detalles', Icons.info_outline),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInput(_isbnController, 'ISBN', Icons.qr_code)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildInput(
                        _yearController, 'Año', Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Ubicación Física', Icons.location_on),
            const SizedBox(height: 20),
            _buildInput(_codigoFisicoController, 'Código Físico (opcional)',
                Icons.qr_code_2),
            const SizedBox(height: 16),
            _buildInput(_locationController, 'Ubicación en Biblioteca',
                Icons.location_on),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.yaviracOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.yaviracOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.yaviracOrange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ejemplo: Estante A-3, Sección 2, Fila 5',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Categorización', Icons.category),
            const SizedBox(height: 20),
            Row(
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
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDropdown(
                  _selectedSubcategory,
                  'Subcategoría',
                  _categories[_selectedCategory]!,
                  (value) => setState(() => _selectedSubcategory = value!),
                )),
              ],
            ),
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

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
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
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
    );
  }

  Widget _buildCoverSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildInput(_coverUrlController, 'URL de la portada',
                  Icons.image_outlined),
            ),
            const SizedBox(width: 12),
            _buildFileButton('PORTADA', Icons.photo_library, _pickCover),
          ],
        ),
        if (_selectedCover != null)
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
                const Icon(Icons.check_circle,
                    color: AppColors.yaviracOrange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Portada: ${_selectedCover!.name}',
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.sidebarGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.yaviracOrange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
            onTap: _isLoading ? null : _addPhysicalBook,
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_location, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'AGREGAR LIBRO FÍSICO',
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
    );
  }
}

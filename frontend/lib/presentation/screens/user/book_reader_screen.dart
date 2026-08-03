import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../theme/glass_theme.dart';

class BookReaderScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  PDFViewController? _pdfController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _localPath;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPDF();
  }

  Future<void> _downloadAndOpenPDF() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.book['id']}.pdf');

      if (await file.exists()) {
        setState(() {
          _localPath = file.path;
          _isDownloading = false;
          _isLoading = false;
        });
        return;
      }

      final dio = Dio();
      await dio.download(
        widget.book['file_url'],
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _localPath = file.path;
        _isDownloading = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error descargando PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GlassTheme.decorationBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // PDF Viewer o Loading
              Expanded(
                child: _isLoading || _isDownloading
                    ? _buildLoadingWidget()
                    : _localPath != null
                        ? _buildBookViewer()
                        : const Center(
                            child: Text(
                              'Error cargando el libro',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
              ),
              
              // Controls
              if (!_isLoading && !_isDownloading && _localPath != null)
                _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GlassmorphicContainer(
            width: 50,
            height: 50,
            borderRadius: 25,
            blur: 15,
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
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book['title'] ?? 'Libro',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.book['author'] ?? 'Autor desconocido',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: GlassmorphicContainer(
        width: 300,
        height: 200,
        borderRadius: 20,
        blur: 20,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              _isDownloading ? 'Descargando libro...' : 'Cargando...',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 10),
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _downloadProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GlassTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${(_downloadProgress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookViewer() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: PDFView(
            filePath: _localPath!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
            onPageError: (page, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error en página $page: $error')),
              );
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfController = pdfViewController;
            },
            onLinkHandler: (String? uri) {
              print('Link: $uri');
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 80,
        borderRadius: 20,
        blur: 15,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Página anterior
            IconButton(
              onPressed: _currentPage > 0
                  ? () {
                      _pdfController?.setPage(_currentPage - 1);
                    }
                  : null,
              icon: Icon(
                Icons.chevron_left,
                color: _currentPage > 0 ? Colors.white : Colors.white30,
                size: 32,
              ),
            ),
            
            // Indicador de página
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: GlassTheme.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPage + 1} / $_totalPages',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Página siguiente
            IconButton(
              onPressed: _currentPage < _totalPages - 1
                  ? () {
                      _pdfController?.setPage(_currentPage + 1);
                    }
                  : null,
              icon: Icon(
                Icons.chevron_right,
                color: _currentPage < _totalPages - 1 ? Colors.white : Colors.white30,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
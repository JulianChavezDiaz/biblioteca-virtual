import 'package:flutter/material.dart';

class OptimizedImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  static final Map<String, ImageProvider> _imageCache = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    // Verificar caché
    if (_imageCache.containsKey(widget.imageUrl)) {
      setState(() => _isLoading = false);
      return;
    }

    // Cargar imagen
    final imageProvider = NetworkImage(widget.imageUrl!);
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);

    imageStream.addListener(ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        _imageCache[widget.imageUrl!] = imageProvider;
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      onError: (exception, stackTrace) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    if (_isLoading) {
      return widget.placeholder ?? _buildPlaceholder();
    }

    return Image(
      image: _imageCache[widget.imageUrl!]!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white54,
          size: 24,
        ),
      ),
    );
  }

  static void clearCache() {
    _imageCache.clear();
  }
}

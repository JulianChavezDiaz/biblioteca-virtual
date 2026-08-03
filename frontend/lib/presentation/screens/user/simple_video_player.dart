import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/optimized_theme.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'stub_html.dart' as html if (dart.library.io) 'stub_html.dart';
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';
import 'stub_ui_web.dart' as ui_web if (dart.library.io) 'stub_ui_web.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const SimpleVideoPlayer({super.key, required this.video});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _hasError = false;
  String? _videoId;
  String? _cleanVideoUrl;
  static final Set<String> _registeredViews = {};

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      // Limpiar caracteres HTML escapados
      _cleanVideoUrl = widget.video['video_id']?.toString() ?? '';
      _cleanVideoUrl = _cleanVideoUrl!
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');

      print('🎥 DEBUG: Clean video URL: $_cleanVideoUrl');

      // Si es MP4, no necesitamos extraer ID
      if (_cleanVideoUrl!.contains('.mp4')) {
        print('🎥 DEBUG: MP4 detected');
        return;
      }

      // Extraer ID de YouTube
      if (_cleanVideoUrl!.contains('youtube.com/watch?v=')) {
        _videoId = _cleanVideoUrl!.split('v=')[1].split('&')[0];
      } else if (_cleanVideoUrl!.contains('youtu.be/')) {
        _videoId = _cleanVideoUrl!.split('youtu.be/')[1].split('?')[0];
      } else if (_cleanVideoUrl!.isNotEmpty && !_cleanVideoUrl!.contains('http')) {
        _videoId = _cleanVideoUrl;
      }

      print('🎥 DEBUG: Extracted video ID: $_videoId');

      // Solo crear controller para móvil
      if (!kIsWeb && _videoId != null && _videoId!.isNotEmpty) {
        _controller = YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else if (_videoId == null || _videoId!.isEmpty) {
        setState(() => _hasError = true);
      }
    } catch (e) {
      print('🎥 ERROR: $e');
      setState(() => _hasError = true);
    }
  }

  Future<void> _openInBrowser() async {
    if (_cleanVideoUrl != null && _cleanVideoUrl!.isNotEmpty) {
      final uri = Uri.parse(_cleanVideoUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video['title'] ?? 'Video',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          Container(
            width: double.infinity,
            height: kIsWeb ? 400 : 250,
            color: Colors.black,
            child: _buildVideoPlayer(),
          ),
          // Video Info
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video['title'] ?? 'Sin título',
                    style: OptimizedTheme.heading3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categoría: ${widget.video['category'] ?? 'Sin categoría'}',
                    style: OptimizedTheme.bodyTextSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  if (widget.video['description']?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Descripción:',
                      style: OptimizedTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.video['description'],
                          style: OptimizedTheme.bodyTextSmall,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    // Para web, usar iframe directo
    if (kIsWeb) {
      return _buildWebPlayer();
    }

    // Para móvil, usar youtube_player_flutter
    if (_controller != null) {
      return YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      );
    }

    return _buildErrorWidget();
  }

  Widget _buildWebPlayer() {
    if (_cleanVideoUrl == null || _cleanVideoUrl!.contains('.mp4')) {
      return _buildMP4Player();
    }

    if (_videoId == null || _videoId!.isEmpty) {
      return _buildErrorWidget();
    }

    if (kIsWeb) {
      final viewType = 'youtube-$_videoId';
      
      if (!_registeredViews.contains(viewType)) {
        _registeredViews.add(viewType);
        ui_web.platformViewRegistry.registerViewFactory(
          viewType,
          (int viewId) {
            final iframe = html.IFrameElement()
              ..src = 'https://www.youtube.com/embed/$_videoId?autoplay=0&controls=1'
              ..allowFullscreen = true;
            iframe.style.border = 'none';
            iframe.style.width = '100%';
            iframe.style.height = '100%';
            return iframe;
          },
        );
      }

      return HtmlElementView(viewType: viewType);
    }
    
    return _buildErrorWidget();
  }

  Widget _buildMP4Player() {
    if (_cleanVideoUrl == null) {
      return _buildErrorWidget();
    }
    
    if (kIsWeb) {
      final viewType = 'mp4-${_cleanVideoUrl.hashCode}';
      
      if (!_registeredViews.contains(viewType)) {
        _registeredViews.add(viewType);
        ui_web.platformViewRegistry.registerViewFactory(
          viewType,
          (int viewId) {
            final video = html.VideoElement()
              ..src = _cleanVideoUrl!
              ..controls = true
              ..autoplay = false;
            video.style.width = '100%';
            video.style.height = '100%';
            video.style.backgroundColor = 'black';
            return video;
          },
        );
      }

      return HtmlElementView(viewType: viewType);
    }
    
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            'Video no disponible',
            style: OptimizedTheme.bodyText.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir en navegador'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
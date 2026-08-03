import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/optimized_theme.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';
import 'stub_html.dart' as html if (dart.library.io) 'stub_html.dart';
import 'stub_ui_web.dart' as ui_web if (dart.library.io) 'stub_ui_web.dart';

class MinimalVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const MinimalVideoPlayer({super.key, required this.video});

  @override
  State<MinimalVideoPlayer> createState() => _MinimalVideoPlayerState();
}

class _MinimalVideoPlayerState extends State<MinimalVideoPlayer> {
  YoutubePlayerController? _controller;
  String? _videoId;
  String? _cleanUrl;
  static final Set<String> _registeredViews = {};

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    _cleanUrl = widget.video['video_id']?.toString() ?? '';
    _cleanUrl = _cleanUrl!
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    print('🎥 Clean URL: $_cleanUrl');

    // Solo para móvil, extraer ID de YouTube
    if (!kIsWeb && _cleanUrl!.contains('youtube.com/watch?v=')) {
      _videoId = _cleanUrl!.split('v=')[1].split('&')[0];
      print('🎥 Video ID: $_videoId');

      if (_videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  Future<void> _openInBrowser() async {
    if (_cleanUrl != null && _cleanUrl!.isNotEmpty) {
      final uri = Uri.parse(_cleanUrl!);
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
        title: Text(widget.video['title'] ?? 'Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
            child: _buildPlayer(),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video['title'] ?? 'Sin título',
                    style: OptimizedTheme.heading3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categoría: ${widget.video['category'] ?? 'Sin categoría'}',
                    style: OptimizedTheme.bodyTextSmall
                        .copyWith(color: Colors.white70),
                  ),
                  if (widget.video['description']?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
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

  Widget _buildPlayer() {
    // Para web, mostrar iframe directo
    if (kIsWeb) {
      if (_cleanUrl != null && _cleanUrl!.contains('youtube.com/watch?v=')) {
        final videoId = _cleanUrl!.split('v=')[1].split('&')[0];
        final viewType = 'iframe-${_cleanUrl.hashCode}';

        // Registrar aquí mismo
        if (!_registeredViews.contains(viewType)) {
          _registeredViews.add(viewType);
          ui_web.platformViewRegistry.registerViewFactory(
            viewType,
            (int id) {
              final iframe = html.IFrameElement()
                ..src =
                    'https://www.youtube.com/embed/$videoId?autoplay=0&controls=1'
                ..allowFullscreen = true;
              iframe.style.border = 'none';
              iframe.style.width = '100%';
              iframe.style.height = '100%';
              return iframe;
            },
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 300,
          child: HtmlElementView(viewType: viewType),
        );
      } else if (_cleanUrl != null && _cleanUrl!.contains('.mp4')) {
        final viewType = 'video-${_cleanUrl.hashCode}';

        // Registrar aquí mismo
        if (!_registeredViews.contains(viewType)) {
          _registeredViews.add(viewType);
          ui_web.platformViewRegistry.registerViewFactory(
            viewType,
            (int id) {
              final video = html.VideoElement()
                ..src = _cleanUrl!
                ..controls = true
                ..autoplay = false;
              video.style.width = '100%';
              video.style.height = '100%';
              video.style.backgroundColor = 'black';
              return video;
            },
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 300,
          child: HtmlElementView(viewType: viewType),
        );
      }
    }

    // Para móvil, usar youtube_player_flutter
    if (_controller != null) {
      return YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
      );
    }

    // Fallback
    return Center(
      child: ElevatedButton.icon(
        onPressed: _openInBrowser,
        icon: const Icon(Icons.open_in_new),
        label: const Text('Abrir Video'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

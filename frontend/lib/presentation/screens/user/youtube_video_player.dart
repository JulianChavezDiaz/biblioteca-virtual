import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/theme/optimized_theme.dart';

class YouTubeVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const YouTubeVideoPlayer({super.key, required this.video});

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _hasError = false;
  String? _originalUrl;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    try {
      final videoIdField = widget.video['video_id'] ?? '';
      print('🎬 DEBUG: Processing video_id: $videoIdField');

      if (videoIdField.isEmpty) {
        print('🎬 DEBUG: Empty video_id');
        setState(() => _hasError = true);
        return;
      }

      String? videoId;

      // Extraer ID de YouTube
      if (videoIdField.contains('youtube.com/watch?v=')) {
        videoId = videoIdField.split('v=')[1].split('&')[0];
        _originalUrl = videoIdField;
      } else if (videoIdField.contains('youtu.be/')) {
        videoId = videoIdField.split('youtu.be/')[1].split('?')[0];
        _originalUrl = 'https://www.youtube.com/watch?v=$videoId';
      } else if (!videoIdField.contains('.mp4') &&
          !videoIdField.contains('http')) {
        // Asumir que es un ID directo
        videoId = videoIdField;
        _originalUrl = 'https://www.youtube.com/watch?v=$videoId';
      }

      print('🎬 DEBUG: Extracted videoId: $videoId');

      if (videoId != null && videoId.isNotEmpty && _isValidYouTubeId(videoId)) {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
            enableCaption: false,
            showVideoAnnotations: false,
            strictRelatedVideos: true,
            interfaceLanguage: 'es',
          ),
        );
        print('🎬 DEBUG: Controller created successfully');
      } else {
        print('🎬 DEBUG: Invalid video ID: $videoId');
        setState(() => _hasError = true);
      }
    } catch (e) {
      print('🎬 DEBUG: Error initializing player: $e');
      setState(() => _hasError = true);
    }
  }

  bool _isValidYouTubeId(String id) {
    // YouTube video IDs son de 11 caracteres alfanuméricos
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);
  }

  Future<void> _openInYouTube() async {
    if (_originalUrl != null) {
      final uri = Uri.parse(_originalUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Player ocupando toda la pantalla
          _hasError || _controller == null
              ? Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white54, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Video no disponible',
                          style: OptimizedTheme.bodyText.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        if (_originalUrl != null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openInYouTube,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Ver en YouTube'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: YoutubePlayer(
                    controller: _controller!,
                  ),
                ),
          // Botón de cerrar flotante
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

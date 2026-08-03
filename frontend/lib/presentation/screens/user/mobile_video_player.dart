import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/optimized_theme.dart';

class MobileVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const MobileVideoPlayer({super.key, required this.video});

  @override
  State<MobileVideoPlayer> createState() => _MobileVideoPlayerState();
}

class _MobileVideoPlayerState extends State<MobileVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _hasError = false;
  String? _videoId;
  final bool _wasFullScreen = false;
  Timer? _focusTimer;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _overlayFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initPlayer();

    // Forzar foco después de un delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _setupFullscreenListener() {
    // Solo logging para debug
    if (_controller != null) {
      _controller!.listen((event) {
        print('🎬 DEBUG: YouTube event: ${event.playerState}');
      });
    }
  }

  void _initPlayer() {
    try {
      final videoIdField = widget.video['video_id'] ?? '';
      print('🎬 DEBUG: Processing video_id: $videoIdField');

      if (videoIdField.isEmpty) {
        setState(() => _hasError = true);
        return;
      }

      // Extraer ID de YouTube
      if (videoIdField.contains('youtube.com/watch?v=')) {
        _videoId = videoIdField.split('v=')[1].split('&')[0];
      } else if (videoIdField.contains('youtu.be/')) {
        _videoId = videoIdField.split('youtu.be/')[1].split('?')[0];
      } else if (!videoIdField.contains('.mp4') &&
          !videoIdField.contains('http')) {
        _videoId = videoIdField;
      }

      print('🎬 DEBUG: Extracted videoId: $_videoId');

      if (_videoId != null &&
          _videoId!.isNotEmpty &&
          _isValidYouTubeId(_videoId!)) {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: _videoId!,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
            enableCaption: false,
          ),
        );
        print('🎬 DEBUG: Controller created successfully');
      } else {
        print('🎬 DEBUG: Invalid video ID: $_videoId');
        setState(() => _hasError = true);
      }
    } catch (e) {
      print('🎬 DEBUG: Error initializing player: $e');
      setState(() => _hasError = true);
    }
  }

  bool _isValidYouTubeId(String id) {
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);
  }

  Future<void> _openInBrowser() async {
    final videoUrl = widget.video['video_id'] ?? '';
    if (videoUrl.isNotEmpty) {
      final uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _focusNode.dispose();
    _overlayFocusNode.dispose();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          print('🎬 DEBUG: ESC pressed - closing video');
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          print('🎬 DEBUG: Back button pressed - closing video');
          return true;
        },
        child: GestureDetector(
          onDoubleTap: () {
            print('🎬 DEBUG: Double tap detected - closing video');
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Reproductor
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
                                style: OptimizedTheme.bodyText
                                    .copyWith(fontSize: 16),
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
                        ),
                      )
                    : YoutubePlayer(
                        controller: _controller!,
                      ),
                // Overlay invisible para capturar ESC
                Positioned.fill(
                  child: Focus(
                    focusNode: _overlayFocusNode,
                    autofocus: true,
                    child: Container(
                      color: Colors.transparent,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                // Información compacta abajo
                if (_controller != null && !_hasError)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.video['title'] ?? 'Sin título',
                                  style: OptimizedTheme.bodyText.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.video['description']?.isNotEmpty ==
                                    true)
                                  Text(
                                    widget.video['description'],
                                    style:
                                        OptimizedTheme.bodyTextSmall.copyWith(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ESC o doble tap para cerrar',
                            style: OptimizedTheme.bodyTextSmall.copyWith(
                              fontSize: 10,
                              color: Colors.white54,
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
      ),
    );
  }
}

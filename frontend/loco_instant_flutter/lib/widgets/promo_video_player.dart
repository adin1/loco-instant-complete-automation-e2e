import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Widget pentru afișarea video-ului promo pe pagina de login
/// Suportă: autoplay, loop, muted, controls, poster image
class PromoVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? posterUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final bool showControls;

  const PromoVideoPlayer({
    super.key,
    required this.videoUrl,
    this.posterUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.autoplay = false,
    this.loop = true,
    this.muted = true,
    this.showControls = true,
  });

  @override
  State<PromoVideoPlayer> createState() => _PromoVideoPlayerState();
}

class _PromoVideoPlayerState extends State<PromoVideoPlayer> {
  late String _viewId;
  html.VideoElement? _videoElement;
  bool _isPlaying = false;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'promo-video-${DateTime.now().millisecondsSinceEpoch}';
    _initializeVideo();
  }

  void _initializeVideo() {
    if (!kIsWeb) return;

    _videoElement = html.VideoElement()
      ..src = widget.videoUrl
      ..autoplay = widget.autoplay
      ..loop = widget.loop
      ..muted = widget.muted
      ..controls = widget.showControls
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '20px';

    if (widget.posterUrl != null) {
      _videoElement!.poster = widget.posterUrl!;
    }

    // Event listeners
    _videoElement!.onLoadedData.listen((_) {
      if (mounted) setState(() => _isLoaded = true);
    });

    _videoElement!.onPlay.listen((_) {
      if (mounted) setState(() => _isPlaying = true);
    });

    _videoElement!.onPause.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _videoElement!.onError.listen((_) {
      if (mounted) setState(() => _hasError = true);
    });

    // Register the view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement!,
    );
  }

  void _togglePlay() {
    if (_videoElement == null) return;
    
    if (_isPlaying) {
      _videoElement!.pause();
    } else {
      _videoElement!.play();
    }
  }

  @override
  void dispose() {
    _videoElement?.pause();
    _videoElement = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
      child: Container(
        width: widget.width,
        height: widget.height ?? 280,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Element
            HtmlElementView(viewType: _viewId),
            
            // Loading indicator
            if (!_isLoaded && !_hasError)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2DD4BF),
                  ),
                ),
              ),
            
            // Error state
            if (_hasError)
              _buildFallback(),
            
            // Custom play button overlay (when paused and no controls)
            if (!widget.showControls && !_isPlaying && _isLoaded)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  color: Colors.black38,
                  child: Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 45,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height ?? 280,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2DD4BF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_outline,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🎬 Video prezentare',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasError ? 'Video indisponibil' : 'LOCO INSTANT',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget simplu care afișează un placeholder când video-ul nu este disponibil
class VideoPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const VideoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height ?? 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F4C81), Color(0xFF1A936F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: _GridPatternPainter(),
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play button
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 50,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      '🎬 Vezi cum funcționează LOCO INSTANT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Duration badge
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '0:45',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/feed_item.dart';

class FeedMediaItem extends StatefulWidget {
  final FeedItem item;
  final bool isActive;
  final bool shouldPreload;
  final bool shouldPlay;

  const FeedMediaItem({
    super.key,
    required this.item,
    required this.isActive,
    this.shouldPreload = false,
    this.shouldPlay = false,
  });

  @override
  State<FeedMediaItem> createState() => _FeedMediaItemState();
}

class _FeedMediaItemState extends State<FeedMediaItem> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  Object? _videoError;
  int _operationId = 0;

  bool get _isVideo =>
      widget.item.videoUrl != null && widget.item.videoUrl!.isNotEmpty;
  bool get _shouldHoldController =>
      _isVideo && (widget.isActive || widget.shouldPreload);
  String get _videoSource => widget.item.videoUrl ?? '';

  @override
  void initState() {
    super.initState();
    _syncControllerLifecycle(forceRecreate: true);
  }

  @override
  void didUpdateWidget(covariant FeedMediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sourceChanged = oldWidget.item.videoUrl != widget.item.videoUrl;
    _syncControllerLifecycle(forceRecreate: sourceChanged);
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _syncControllerLifecycle({bool forceRecreate = false}) {
    if (!_shouldHoldController) {
      _disposeController();
      return;
    }

    if (forceRecreate) {
      _disposeController();
    }

    if (_controller == null && !_isInitializing) {
      _initializeController();
      return;
    }

    _syncPlayback();
  }

  Future<void> _initializeController() async {
    if (_videoSource.isEmpty || _isInitializing) return;
    setState(() {
      _isInitializing = true;
      _videoError = null;
    });

    final opId = ++_operationId;
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(_videoSource));

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(1.0);

      if (!mounted || opId != _operationId) {
        await controller.dispose();
        return;
      }

      final oldController = _controller;
      _controller = controller;
      await oldController?.dispose();

      setState(() {
        _isInitializing = false;
      });
      _syncPlayback();
    } catch (e) {
      await controller.dispose();
      if (!mounted || opId != _operationId) return;
      setState(() {
        _isInitializing = false;
        _videoError = e;
        _controller = null;
      });
    }
  }

  void _disposeController() {
    _operationId++;
    final oldController = _controller;
    _controller = null;
    _isInitializing = false;
    if (oldController != null) {
      oldController.pause();
      oldController.dispose();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (widget.isActive && widget.shouldPlay) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  void _retryVideo() {
    setState(() {
      _videoError = null;
    });
    _syncControllerLifecycle(forceRecreate: true);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: _isVideo ? _buildVideoContent() : _buildImageContent(),
    );
  }

  Widget _buildVideoContent() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      final size = controller.value.size;
      if (size.width > 0 && size.height > 0) {
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(controller),
            ),
          ),
        );
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildFallbackImage(),
        if (_isInitializing)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ),
        if (_videoError != null)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 38,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _retryVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    final source = (widget.item.thumbUrl ?? widget.item.mediaUrl).trim();
    if (source.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildPlaceholder(),
            Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFD4AF37),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    final fallback = (widget.item.thumbUrl ?? '').trim();
    if (fallback.isEmpty) {
      return _buildPlaceholder();
    }
    return Image.network(
      fallback,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 46),
      ),
    );
  }
}

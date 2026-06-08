import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/video_metadata.dart';

class PostVideoPlayer extends StatefulWidget {
  const PostVideoPlayer({super.key, required this.metadata});

  final VideoMetadata metadata;

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(File(widget.metadata.path));
    _ctrl.initialize().then((_) {
      if (!mounted) return;
      _ctrl.setLooping(true);
      _ctrl.setVolume(0);
      setState(() => _initialized = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _ctrl.setVolume(_muted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.metadata.thumbnailBytes != null)
                Image.memory(
                  widget.metadata.thumbnailBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              else
                const ColoredBox(color: Colors.black12),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return VisibilityDetector(
      key: Key('video-${widget.metadata.path}'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (info.visibleFraction > 0.5) {
          _ctrl.play();
        } else {
          _ctrl.pause();
        }
      },
      child: GestureDetector(
        onTap: _toggleMute,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              AspectRatio(
                aspectRatio: _ctrl.value.aspectRatio,
                child: VideoPlayer(_ctrl),
              ),
              // Duration at bottom-left
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.metadata.durationDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Mute toggle at bottom-right
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


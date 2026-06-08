import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../../models/post_model.dart';
import '../../../models/video_metadata.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../feed/presentation/feed_providers.dart';
import '../../profile/presentation/profile_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.replyToId});

  final String? replyToId;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  VideoMetadata? _videoMetadata;
  static const _maxLength = 280;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _videoMetadata = null;
    });
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    // Validate .mp4 file format
    if (!_isValidMp4File(path)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid .mp4 video file'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // Extract video metadata
      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();

      final duration = controller.value.duration;
      final thumbnail = await _generateThumbnail(controller);

      controller.dispose();

      setState(() {
        _videoMetadata = VideoMetadata(
          path: path,
          duration: duration,
          thumbnailBytes: thumbnail,
        );
        _imageBytes = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _isValidMp4File(String path) {
    final extension = path.toLowerCase().split('.').last;
    return extension == 'mp4';
  }

  Future<Uint8List?> _generateThumbnail(VideoPlayerController controller) async {
    try {
      await controller.seekTo(const Duration(milliseconds: 100));
      return null; // Thumbnail generation would require additional packages
    } catch (e) {
      return null;
    }
  }

  void _removeMedia() => setState(() {
        _imageBytes = null;
        _videoMetadata = null;
      });

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _imageBytes == null && _videoMetadata == null) return;

    final author = ref.read(profileProvider).user;

    await ref.read(feedProvider.notifier).addPost(PostModel(
          id: const Uuid().v4(),
          author: author,
          content: text,
          createdAt: DateTime.now(),
          replyToId: widget.replyToId,
          imageBytes: _imageBytes,
          videoMetadata: _videoMetadata,
        ));

    if (mounted) context.pop();
  }

  bool get _canPost =>
      _controller.text.trim().isNotEmpty ||
      _imageBytes != null ||
      _videoMetadata != null;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = ref.watch(profileProvider).user;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton(
              onPressed: _canPost ? _submit : null,
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(widget.replyToId != null ? 'Reply' : 'Post'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(user: currentUser),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          maxLength: _maxLength,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: widget.replyToId != null
                                ? 'Post your reply'
                                : "What's happening?",
                            border: InputBorder.none,
                            counterStyle: TextStyle(color: muted),
                          ),
                          style: const TextStyle(fontSize: 18),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  if (_imageBytes != null) ...[
                    const SizedBox(height: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              cacheWidth: 800),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeMedia,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_videoMetadata != null) ...[
                    const SizedBox(height: 12),
                    _VideoPreview(
                      metadata: _videoMetadata!,
                      onRemove: _removeMedia,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image_outlined, color: colorScheme.primary),
                    tooltip: 'Add photo',
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.videocam_outlined, color: colorScheme.primary),
                    tooltip: 'Add video',
                    onPressed: _pickVideo,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({
    required this.metadata,
    required this.onRemove,
  });

  final VideoMetadata metadata;
  final VoidCallback onRemove;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.file(File(widget.metadata.path));
    _ctrl.initialize().then((_) {
      if (!mounted) return;
      _ctrl.setLooping(true);
      _ctrl.play();
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _ready
              ? AspectRatio(
                  aspectRatio: _ctrl.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      VideoPlayer(_ctrl),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
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
                    ],
                  ),
                )
              : const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

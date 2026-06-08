/// Data model for video metadata and properties.
/// 
/// Stores information about videos attached to posts, including:
/// - File path or URL
/// - Duration
/// - Thumbnail image (as bytes)
/// - File size
/// 
/// Provides formatting for displaying video duration.
library;

import 'dart:typed_data';

class VideoMetadata {
  // Path or URL to the video file
  final String path;
  // Duration of the video
  final Duration duration;
  // Thumbnail image as raw bytes
  final Uint8List? thumbnailBytes;
  // Size of the video file in bytes
  final int? fileSizeBytes;

  const VideoMetadata({
    required this.path,
    required this.duration,
    this.thumbnailBytes,
    this.fileSizeBytes,
  });

  /// Returns a formatted string of the video duration (e.g., "3:45").
  String get durationDisplay {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

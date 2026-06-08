/// Data model representing a post/tweet in the feed.
/// 
/// A post contains:
/// - Content text and optional media (image or video)
/// - Author information
/// - Engagement metrics (likes, replies, reposts)
/// - Creation timestamp
/// - Optional reply-to post ID for threaded conversations
/// 
/// The model includes JSON serialization for storage/transmission.
library;

import 'dart:convert';
import 'dart:typed_data';
import 'user_model.dart';
import 'video_metadata.dart';

class PostModel {
  // Unique identifier for the post
  final String id;
  // User who created this post
  final UserModel author;
  // Text content of the post
  final String content;
  // When this post was created
  final DateTime createdAt;
  // Number of likes on this post
  final int likesCount;
  // Number of replies to this post
  final int repliesCount;
  // Number of times this post was reposted
  final int repostsCount;
  // Whether the current user has liked this post
  final bool isLiked;
  // Whether the current user has reposted this post
  final bool isReposted;
  // If this is a reply, the ID of the post being replied to
  final String? replyToId;
  // Raw image bytes if an image was attached (for new posts)
  final Uint8List? imageBytes;
  // URL to image if already stored (for fetched posts)
  final String? imageUrl;
  // Video metadata if a video was attached
  final VideoMetadata? videoMetadata;

  const PostModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.repostsCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.replyToId,
    this.imageBytes,
    this.imageUrl,
    this.videoMetadata,
  });

  /// Creates a copy of this post with specified fields updated.
  /// Useful for updating like/repost counts and status without recreating the entire object.
  PostModel copyWith({
    int? likesCount,
    bool? isLiked,
    int? repostsCount,
    bool? isReposted,
    int? repliesCount,
  }) {
    return PostModel(
      id: id,
      author: author,
      content: content,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      replyToId: replyToId,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
      videoMetadata: videoMetadata,
    );
  }

  /// Converts post to JSON for storage or transmission.
  /// Encodes image and video bytes to base64 strings.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': {
        'id': author.id,
        'username': author.username,
        'displayName': author.displayName,
        'bio': author.bio,
        'avatarUrl': author.avatarUrl,
        'bannerUrl': author.bannerUrl,
        'pronouns': author.pronouns,
        'age': author.age,
        'followersCount': author.followersCount,
        'followingCount': author.followingCount,
      },
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'repostsCount': repostsCount,
      'isLiked': isLiked,
      'isReposted': isReposted,
      'replyToId': replyToId,
      // Encode image bytes to base64 string for JSON
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'imageUrl': imageUrl,
      // Encode video metadata including thumbnail
      'videoMetadata': videoMetadata != null
          ? {
              'path': videoMetadata!.path,
              'durationMs': videoMetadata!.duration.inMilliseconds,
              'thumbnailBytes': videoMetadata!.thumbnailBytes != null
                  ? base64Encode(videoMetadata!.thumbnailBytes!)
                  : null,
              'fileSizeBytes': videoMetadata!.fileSizeBytes,
            }
          : null,
    };
  }

  /// Creates a PostModel from JSON data.
  /// Decodes base64 image/video bytes back to raw bytes.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse author data from nested JSON
    final authorData = json['author'] as Map<String, dynamic>;
    final author = UserModel(
      id: authorData['id'] as String,
      username: authorData['username'] as String,
      displayName: authorData['displayName'] as String,
      bio: authorData['bio'] as String?,
      avatarUrl: authorData['avatarUrl'] as String?,
      bannerUrl: authorData['bannerUrl'] as String?,
      pronouns: authorData['pronouns'] as String?,
      age: authorData['age'] as int?,
      followersCount: authorData['followersCount'] as int? ?? 0,
      followingCount: authorData['followingCount'] as int? ?? 0,
    );

    // Parse video metadata if present
    VideoMetadata? videoMetadata;
    if (json['videoMetadata'] != null) {
      final videoData = json['videoMetadata'] as Map<String, dynamic>;
      final thumbnailStr = videoData['thumbnailBytes'] as String?;
      videoMetadata = VideoMetadata(
        path: videoData['path'] as String,
        duration: Duration(milliseconds: videoData['durationMs'] as int),
        // Decode base64 thumbnail back to bytes
        thumbnailBytes:
            thumbnailStr != null ? base64Decode(thumbnailStr) : null,
        fileSizeBytes: videoData['fileSizeBytes'] as int?,
      );
    }

    // Decode base64 image bytes if present
    final imageBytesStr = json['imageBytes'] as String?;

    return PostModel(
      id: json['id'] as String,
      author: author,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likesCount: json['likesCount'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      repostsCount: json['repostsCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isReposted: json['isReposted'] as bool? ?? false,
      replyToId: json['replyToId'] as String?,
      // Decode base64 image bytes
      imageBytes: imageBytesStr != null ? base64Decode(imageBytesStr) : null,
      imageUrl: json['imageUrl'] as String?,
      videoMetadata: videoMetadata,
    );
  }
}

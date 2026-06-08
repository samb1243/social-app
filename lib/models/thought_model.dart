/// Data model representing a temporary "thought" (24-hour disappearing post).
/// 
/// Thoughts are similar to Stories - they appear for 24 hours then disappear.
/// They contain:
/// - Author information
/// - Text content
/// - Expiration time (24 hours from creation)
/// 
/// Includes helper methods to check if a thought has expired and calculate time remaining.
library;

import 'user_model.dart';

class ThoughtModel {
  // Unique identifier for the thought
  final String id;
  // User who posted this thought
  final UserModel author;
  // Text content of the thought
  final String content;
  // When this thought was created
  final DateTime createdAt;
  // When this thought expires and should be removed
  final DateTime expiresAt;

  const ThoughtModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Checks if this thought has expired (current time is past expiresAt).
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Calculates how long until this thought expires.
  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  /// Creates a copy of this thought with specified fields updated.
  ThoughtModel copyWith({
    String? id,
    UserModel? author,
    String? content,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return ThoughtModel(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Converts thought to JSON for storage or transmission.
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
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Creates a ThoughtModel from JSON data.
  factory ThoughtModel.fromJson(Map<String, dynamic> json) {
    // Parse author data
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

    return ThoughtModel(
      id: json['id'] as String,
      author: author,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

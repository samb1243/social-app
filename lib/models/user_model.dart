/// Data model representing a user in the application.
/// 
/// Contains user profile information like username, display name, bio, etc.
/// Each user has an immutable ID and follower/following counts.
/// 
/// Use copyWith() method to create a modified copy of a user with updated fields.
library;

class UserModel {
  // Unique identifier for the user
  final String id;
  // Username (used for @mentions) - must be unique
  final String username;
  // Display name shown on profile
  final String displayName;
  // User's bio/about section
  final String? bio;
  // URL to user's profile picture
  final String? avatarUrl;
  // URL to user's banner/header image
  final String? bannerUrl;
  // User's pronouns (e.g., "they/them", "she/her")
  final String? pronouns;
  // User's age (optional)
  final int? age;
  // Number of followers this user has
  final int followersCount;
  // Number of users this user is following
  final int followingCount;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.pronouns,
    this.age,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  /// Creates a copy of this user with specified fields replaced.
  /// 
  /// Use clearPronouns, clearAge, clearBio flags to explicitly remove those fields.
  /// Otherwise, non-null parameters will override existing values.
  UserModel copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    String? pronouns,
    int? age,
    int? followersCount,
    int? followingCount,
    bool clearPronouns = false,
    bool clearAge = false,
    bool clearBio = false,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: clearBio ? null : bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      pronouns: clearPronouns ? null : pronouns ?? this.pronouns,
      age: clearAge ? null : age ?? this.age,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

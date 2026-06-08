/// Mock data for development and testing.
/// 
/// Provides sample users, current user, and posts for populating the UI
/// when a backend is not yet available.
/// 
/// Use this data in providers to fill the feed during development.
library;

import 'user_model.dart';
import 'post_model.dart';

/// Sample users to populate the feed with realistic content
final mockUsers = [
  const UserModel(
    id: 'u1',
    username: 'alice',
    displayName: 'Alice Chen',
    bio: 'Building things • Coffee enthusiast',
    followersCount: 1240,
    followingCount: 380,
  ),
  const UserModel(
    id: 'u2',
    username: 'bob_dev',
    displayName: 'Bob Martinez',
    bio: 'Software engineer. Opinions my own.',
    followersCount: 890,
    followingCount: 210,
  ),
  const UserModel(
    id: 'u3',
    username: 'techwriter',
    displayName: 'Sarah K.',
    bio: 'Writing about tech for humans.',
    followersCount: 5600,
    followingCount: 140,
  ),
];

/// The current logged-in user (used for testing)
final mockCurrentUser = const UserModel(
  id: 'me',
  username: 'you',
  displayName: 'Your Name',
  bio: 'Just joined!',
  followersCount: 0,
  followingCount: 3,
);

/// Sample posts for the feed
final mockPosts = [
  PostModel(
    id: 'p1',
    author: mockUsers[0],
    content:
        'Just shipped a new feature after three days of debugging. The bug was a missing semicolon. I need a vacation.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    likesCount: 84,
    repliesCount: 9,
    repostsCount: 14,
  ),
  PostModel(
    id: 'p2',
    author: mockUsers[2],
    content:
        'Hot take: the best API documentation is the one that shows you exactly what you get back from the endpoint, not just what you send. Examples > schemas every time.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    likesCount: 312,
    repliesCount: 41,
    repostsCount: 78,
    isLiked: true,
  ),
  PostModel(
    id: 'p3',
    author: mockUsers[1],
    content:
        'Reminder that "it works on my machine" is actually a great starting point for debugging. It tells you the problem is environmental.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    likesCount: 1100,
    repliesCount: 55,
    repostsCount: 230,
  ),
  PostModel(
    id: 'p4',
    author: mockUsers[0],
    content: 'Switched to a standing desk six months ago. Update: I now sit on the floor.',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    likesCount: 2400,
    repliesCount: 88,
    repostsCount: 410,
    isLiked: true,
    isReposted: true,
  ),
  PostModel(
    id: 'p5',
    author: mockUsers[2],
    content:
        'The real 10x developer skill is knowing when NOT to write code.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    likesCount: 5800,
    repliesCount: 120,
    repostsCount: 920,
  ),
];

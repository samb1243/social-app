/// Service for persisting posts to device storage.
/// 
/// Uses SharedPreferences to save and load posts for each user.
/// Each user's posts are stored under a unique key based on their user ID.
/// 
/// Posts are serialized to JSON before storage and deserialized when loading.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class PostStorageService {
  static const String _postsKeyPrefix = 'saved_posts_';
  static const String _likesKeyPrefix = 'user_likes_';
  static const String _repostsKeyPrefix = 'user_reposts_';

  /// Generates the storage key for a specific user's posts.
  static String _getPostsKey(String userId) => '$_postsKeyPrefix$userId';

  /// Saves all posts for a user to device storage.
  /// 
  /// Converts posts to JSON, encodes as string, and stores in SharedPreferences.
  /// Posts are associated with the user ID.
  static Future<void> savePosts(String userId, List<PostModel> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert each post to JSON
      final jsonList = posts.map((post) => post.toJson()).toList();
      // Encode list to JSON string
      final jsonString = jsonEncode(jsonList);
      // Store in SharedPreferences with user-specific key
      await prefs.setString(_getPostsKey(userId), jsonString);
    } catch (e) {
      print('Error saving posts: $e');
    }
  }

  /// Loads all saved posts for a user from device storage.
  /// 
  /// Returns empty list if no posts are saved or on error.
  /// Deserializes JSON back to PostModel objects.
  static Future<List<PostModel>> loadPosts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Get the JSON string from SharedPreferences
      final jsonString = prefs.getString(_getPostsKey(userId));
      // Return empty list if no data found
      if (jsonString == null) {
        return [];
      }
      // Decode JSON string to list
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      // Convert each JSON object to PostModel
      return jsonList
          .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading posts: $e');
      return [];
    }
  }

  /// Clears all saved posts for a user from device storage.
  static Future<void> clearPosts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getPostsKey(userId));
    } catch (e) {
      print('Error clearing posts: $e');
    }
  }

  /// Saves the set of post IDs that a user has liked.
  static Future<void> saveLikes(String userId, Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$_likesKeyPrefix$userId', jsonEncode(ids.toList()));
    } catch (_) {}
  }

  /// Loads the set of post IDs that a user has liked.
  static Future<Set<String>> loadLikes(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString('$_likesKeyPrefix$userId');
      if (s == null) return {};
      return (jsonDecode(s) as List).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  /// Saves the set of post IDs that a user has reposted.
  static Future<void> saveReposts(String userId, Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$_repostsKeyPrefix$userId', jsonEncode(ids.toList()));
    } catch (_) {}
  }

  /// Loads the set of post IDs that a user has reposted.
  static Future<Set<String>> loadReposts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString('$_repostsKeyPrefix$userId');
      if (s == null) return {};
      return (jsonDecode(s) as List).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }
}


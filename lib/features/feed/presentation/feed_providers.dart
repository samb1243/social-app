library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../services/post_storage_service.dart';
import '../../auth/presentation/auth_providers.dart';

class FeedNotifier extends Notifier<List<PostModel>> {
  static const _globalKey = '__global__';

  @override
  List<PostModel> build() {
    // Listen (not watch) so the notifier is never torn down on user change.
    // Instead we clear stale flags immediately and reload for the new user.
    ref.listen<UserModel?>(authProvider, (prev, next) {
      if (prev?.id != next?.id) {
        // Instantly wipe per-user flags so the old account's hearts don't show
        if (state.isNotEmpty) {
          state = state
              .map((p) => p.copyWith(isLiked: false, isReposted: false))
              .toList();
        }
        Future.microtask(_loadPosts);
      }
    });

    Future.microtask(_loadPosts);
    return [];
  }

  Future<void> _loadPosts() async {
    final userId = ref.read(authProvider)?.id;
    final raw = await PostStorageService.loadPosts(_globalKey);

    if (userId == null) {
      state = raw
          .map((p) => p.copyWith(isLiked: false, isReposted: false))
          .toList();
      return;
    }

    final likedIds = await PostStorageService.loadLikes(userId);
    final repostedIds = await PostStorageService.loadReposts(userId);

    state = raw
        .map((p) => p.copyWith(
              isLiked: likedIds.contains(p.id),
              isReposted: repostedIds.contains(p.id),
            ))
        .toList();
  }

  Future<void> toggleLike(String postId) async {
    final userId = ref.read(authProvider)?.id;
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            isLiked: !p.isLiked,
            likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
          )
        else
          p,
    ];
    await _persist(userId);
  }

  Future<void> toggleRepost(String postId) async {
    final userId = ref.read(authProvider)?.id;
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            isReposted: !p.isReposted,
            repostsCount:
                p.isReposted ? p.repostsCount - 1 : p.repostsCount + 1,
          )
        else
          p,
    ];
    await _persist(userId);
  }

  Future<void> addPost(PostModel post) async {
    final userId = ref.read(authProvider)?.id;
    state = [post, ...state];
    await _persist(userId);
  }

  Future<void> _persist(String? userId) async {
    // Strip per-user flags before writing to global storage — they must never
    // bleed across accounts.
    final stripped = state
        .map((p) => p.copyWith(isLiked: false, isReposted: false))
        .toList();
    await PostStorageService.savePosts(_globalKey, stripped);

    if (userId == null) return;

    final likedIds =
        state.where((p) => p.isLiked).map((p) => p.id).toSet();
    final repostedIds =
        state.where((p) => p.isReposted).map((p) => p.id).toSet();

    await Future.wait([
      PostStorageService.saveLikes(userId, likedIds),
      PostStorageService.saveReposts(userId, repostedIds),
    ]);
  }
}

final feedProvider =
    NotifierProvider<FeedNotifier, List<PostModel>>(FeedNotifier.new);

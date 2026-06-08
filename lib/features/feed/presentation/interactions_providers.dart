import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/post_storage_service.dart';
import '../../auth/presentation/auth_providers.dart';

class UserInteractions {
  final Set<String> likedIds;
  final Set<String> repostedIds;

  const UserInteractions({
    this.likedIds = const {},
    this.repostedIds = const {},
  });

  UserInteractions copyWith({
    Set<String>? likedIds,
    Set<String>? repostedIds,
  }) =>
      UserInteractions(
        likedIds: likedIds ?? this.likedIds,
        repostedIds: repostedIds ?? this.repostedIds,
      );
}

class UserInteractionsNotifier extends Notifier<UserInteractions> {
  @override
  UserInteractions build() {
    final userId = ref.watch(authProvider)?.id;
    debugPrint('[Interactions] build() called — userId=$userId, '
        'current likedIds=${state.likedIds}');

    if (userId != null) {
      Future.microtask(() => _load(userId));
    }
    return const UserInteractions();
  }

  Future<void> _load(String userId) async {
    debugPrint('[Interactions] _load() start — userId=$userId');
    final liked = await PostStorageService.loadLikes(userId);
    final reposted = await PostStorageService.loadReposts(userId);
    debugPrint('[Interactions] _load() done  — liked=$liked  reposted=$reposted');
    state = UserInteractions(likedIds: liked, repostedIds: reposted);
  }

  Future<void> toggleLike(String postId) async {
    final userId = ref.read(authProvider)?.id;
    final next = Set<String>.from(state.likedIds);
    if (next.contains(postId)) {
      next.remove(postId);
    } else {
      next.add(postId);
    }
    debugPrint('[Interactions] toggleLike — userId=$userId  postId=$postId  '
        'newLikedIds=$next');
    state = state.copyWith(likedIds: next);
    if (userId != null) await PostStorageService.saveLikes(userId, next);
  }

  Future<void> toggleRepost(String postId) async {
    final userId = ref.read(authProvider)?.id;
    final next = Set<String>.from(state.repostedIds);
    if (next.contains(postId)) {
      next.remove(postId);
    } else {
      next.add(postId);
    }
    debugPrint('[Interactions] toggleRepost — userId=$userId  postId=$postId  '
        'newRepostedIds=$next');
    state = state.copyWith(repostedIds: next);
    if (userId != null) await PostStorageService.saveReposts(userId, next);
  }

  bool isLiked(String postId) => state.likedIds.contains(postId);
  bool isReposted(String postId) => state.repostedIds.contains(postId);
}

final userInteractionsProvider =
    NotifierProvider<UserInteractionsNotifier, UserInteractions>(
        UserInteractionsNotifier.new);

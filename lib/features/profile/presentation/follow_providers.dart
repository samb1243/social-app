import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  bool isFollowing(String userId) => state.contains(userId);

  void follow(String userId) {
    state = {...state, userId};
  }

  void unfollow(String userId) {
    state = {...state}..remove(userId);
  }

  void toggle(String userId) {
    if (isFollowing(userId)) {
      unfollow(userId);
    } else {
      follow(userId);
    }
  }
}

final followProvider =
    NotifierProvider<FollowNotifier, Set<String>>(FollowNotifier.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user_model.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../user_profile/presentation/user_profile_providers.dart';
import 'follow_providers.dart';

class FollowListScreen extends ConsumerWidget {
  const FollowListScreen({
    super.key,
    required this.userId,
    required this.mode,
  });

  final String userId;
  final String mode; // 'followers' or 'following'

  List<UserModel> _users({
    required String? currentUserId,
    required Set<String> followedIds,
    required Map<String, UserModel> allUsers,
  }) {
    if (mode == 'following' && userId == currentUserId) {
      // Real data: everyone the current user follows.
      return followedIds
          .map((id) => allUsers[id])
          .whereType<UserModel>()
          .toList();
    }

    if (mode == 'followers' && userId != currentUserId) {
      // If the current user follows this person, show them in the followers list.
      if (followedIds.contains(userId) && currentUserId != null) {
        final cu = allUsers[currentUserId];
        if (cu != null) return [cu];
      }
    }

    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider)?.id;
    final followedIds = ref.watch(followProvider);
    final allUsers = ref.watch(allUsersProvider);
    final viewedUser = allUsers[userId];

    final users = _users(
      currentUserId: currentUserId,
      followedIds: followedIds,
      allUsers: allUsers,
    );

    final title = mode == 'following' ? 'Following' : 'Followers';
    final muted = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (viewedUser != null)
              Text('@${viewedUser.username}',
                  style: TextStyle(fontSize: 12, color: muted)),
          ],
        ),
      ),
      body: users.isEmpty
          ? Center(
              child: Text('No $title yet', style: TextStyle(color: muted)),
            )
          : ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _UserTile(user: users[i]),
            ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider)?.id;
    final followedIds = ref.watch(followProvider);
    final isMe = user.id == currentUserId;
    final isFollowing = followedIds.contains(user.id);

    void goToProfile() {
      if (isMe) {
        context.go('/profile');
      } else {
        context.push('/user/${user.id}');
      }
    }

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: GestureDetector(
        onTap: goToProfile,
        child: UserAvatar(user: user),
      ),
      title: Text(user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('@${user.username}'),
      trailing: isMe
          ? null
          : isFollowing
              ? OutlinedButton(
                  onPressed: () =>
                      ref.read(followProvider.notifier).unfollow(user.id),
                  child: const Text('Following'),
                )
              : FilledButton(
                  onPressed: () =>
                      ref.read(followProvider.notifier).follow(user.id),
                  child: const Text('Follow'),
                ),
      onTap: goToProfile,
    );
  }
}

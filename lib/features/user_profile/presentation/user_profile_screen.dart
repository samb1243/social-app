import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../feed/presentation/feed_providers.dart';
import '../../feed/presentation/widgets/post_card.dart';
import '../../profile/presentation/follow_providers.dart';
import 'user_profile_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userByIdProvider(userId));
    final currentUserId = ref.watch(authProvider)?.id;
    final isMe = currentUserId == userId;
    final followedIds = ref.watch(followProvider);
    final isFollowing = followedIds.contains(userId);
    final allPosts = ref.watch(feedProvider);
    final userPosts = allPosts.where((p) => p.author.id == userId).toList();
    final muted = Theme.of(context).textTheme.bodyMedium?.color;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }

    final displayedFollowersCount =
        user.followersCount + (isFollowing ? 1 : 0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: Text(user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            floating: true,
          ),
          SliverToBoxAdapter(child: _UserBanner(user: user)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isMe)
                        OutlinedButton(
                          onPressed: () => context.push('/edit-profile'),
                          child: const Text('Edit profile'),
                        )
                      else
                        _FollowButton(
                          isFollowing: isFollowing,
                          onPressed: () =>
                              ref.read(followProvider.notifier).toggle(userId),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(user.displayName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('@${user.username}',
                      style: TextStyle(color: muted)),
                  if (user.pronouns != null) ...[
                    const SizedBox(height: 2),
                    Text(user.pronouns!,
                        style: TextStyle(color: muted, fontSize: 13)),
                  ],
                  if (user.age != null) ...[
                    const SizedBox(height: 2),
                    Text('Age ${user.age}',
                        style: TextStyle(color: muted, fontSize: 13)),
                  ],
                  if (user.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(user.bio!),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FollowStat(
                        count: user.followingCount,
                        label: 'Following',
                        onTap: () => context.push(
                            '/follow-list?userId=$userId&mode=following'),
                      ),
                      const SizedBox(width: 20),
                      _FollowStat(
                        count: displayedFollowersCount,
                        label: 'Followers',
                        onTap: () => context.push(
                            '/follow-list?userId=$userId&mode=followers'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          if (userPosts.isEmpty)
            SliverFillRemaining(
              child: Center(
                  child:
                      Text('No posts yet', style: TextStyle(color: muted))),
            )
          else
            SliverList.separated(
              itemCount: userPosts.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, i) => PostCard(post: userPosts[i]),
            ),
        ],
      ),
    );
  }
}

class _UserBanner extends StatelessWidget {
  const _UserBanner({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    final Widget background = user.bannerUrl != null
        ? Image.network(user.bannerUrl!,
            height: 120, width: double.infinity, fit: BoxFit.cover)
        : Container(height: 120, color: colorScheme.primaryContainer);

    final ImageProvider? avatarImage =
        user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        background,
        Positioned(
          bottom: -36,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scaffoldBg, width: 4),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowing, required this.onPressed});
  final bool isFollowing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isFollowing) {
      return OutlinedButton(
        onPressed: onPressed,
        child: const Text('Following'),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      child: const Text('Follow'),
    );
  }
}

class _FollowStat extends StatelessWidget {
  const _FollowStat({required this.count, required this.label, this.onTap});
  final int count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final text = RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$count',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          TextSpan(text: ' $label', style: TextStyle(color: muted)),
        ],
      ),
    );
    if (onTap == null) return text;
    return GestureDetector(onTap: onTap, child: text);
  }
}

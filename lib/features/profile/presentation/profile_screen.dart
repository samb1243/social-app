import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user_model.dart';
import '../../../shared/widgets/user_avatar.dart';
import 'follow_providers.dart';
import 'profile_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../feed/presentation/feed_providers.dart';
import '../../feed/presentation/widgets/post_card.dart';
import '../../feed/presentation/thought_card.dart';
import '../../feed/presentation/create_thought_dialog.dart';
import '../../feed/presentation/thoughts_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;
    final followedIds = ref.watch(followProvider);
    final posts = ref.watch(feedProvider);
    final thoughts = ref.watch(activeThoughtsProvider);
    final userThoughts = thoughts.where((t) => t.author.id == user.id).toList();
    final userPosts = posts.where((p) => p.author.id == user.id).toList();
    final muted = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            floating: true,
          ),
          SliverToBoxAdapter(child: _Banner(state: profileState, currentUser: user, ref: ref)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.push('/edit-profile'),
                        child: const Text('Edit profile'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => ref.read(authProvider.notifier).logout(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.error,
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                  // Space to clear the avatar which extends 56px below the banner
                  const SizedBox(height: 20),
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
                        count: followedIds.length,
                        label: 'Following',
                        onTap: () => context.push(
                            '/follow-list?userId=${user.id}&mode=following'),
                      ),
                      const SizedBox(width: 20),
                      _FollowStat(
                        count: user.followersCount,
                        label: 'Followers',
                        onTap: () => context.push(
                            '/follow-list?userId=${user.id}&mode=followers'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          if (userThoughts.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ThoughtCard(
                  thought: userThoughts[index],
                  onDelete: () {
                    ref.read(thoughtsProvider.notifier).removeThought(userThoughts[index].id);
                  },
                ),
                childCount: userThoughts.length,
              ),
            ),
          if (userThoughts.isNotEmpty)
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

class _Banner extends ConsumerWidget {
  const _Banner({
    required this.state,
    required this.currentUser,
    required this.ref,
  });
  
  final ProfileState state;
  final UserModel currentUser;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget background;
    if (state.localBanner != null) {
      background = Image.memory(state.localBanner!,
          height: 120, width: double.infinity, fit: BoxFit.cover);
    } else if (state.user.bannerUrl != null) {
      background = Image.network(state.user.bannerUrl!,
          height: 120, width: double.infinity, fit: BoxFit.cover);
    } else {
      background =
          Container(height: 120, color: colorScheme.primaryContainer);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        background,
        Positioned(
          bottom: -56,
          left: 16,
          child: _AvatarDisplay(state: state, currentUser: state.user, onCreateThought: () {
            showDialog(
              context: context,
              builder: (ctx) => CreateThoughtDialog(currentUser: state.user),
            );
          }),
        ),
      ],
    );
  }
}

class _AvatarDisplay extends StatefulWidget {
  const _AvatarDisplay({
    required this.state,
    required this.currentUser,
    required this.onCreateThought,
  });
  
  final ProfileState state;
  final UserModel currentUser;
  final VoidCallback onCreateThought;

  @override
  State<_AvatarDisplay> createState() => _AvatarDisplayState();
}

class _AvatarDisplayState extends State<_AvatarDisplay> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    ImageProvider? image;
    if (widget.state.localAvatar != null) {
      image = MemoryImage(widget.state.localAvatar!);
    } else if (widget.state.user.avatarUrl != null) {
      image = NetworkImage(widget.state.user.avatarUrl!);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scaffoldBg, width: 4),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: avatarColorFor(widget.state.user.displayName),
              backgroundImage: image,
              child: image == null
                  ? Text(
                      widget.state.user.displayName.isNotEmpty
                          ? widget.state.user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
          if (_isHovering)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onCreateThought,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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

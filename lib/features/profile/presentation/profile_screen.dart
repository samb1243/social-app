import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/post_model.dart';
import '../../../models/thought_model.dart';
import '../../../models/user_model.dart';
import '../../../shared/widgets/glass_container.dart';
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
    final userThoughts =
        thoughts.where((t) => t.author.id == user.id).toList();
    final userPosts = posts.where((p) => p.author.id == user.id).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor:
                  const Color(0xFF080A1C).withValues(alpha: 0.65),
              title: Text(
                user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                final profileCol = _ProfileColumn(
                  profileState: profileState,
                  user: user,
                  followedIds: followedIds,
                  userThoughts: userThoughts,
                  userPosts: userPosts,
                );

                if (!isWide) return profileCol;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: profileCol),
                        const VerticalDivider(width: 1, thickness: 0.5),
                        SizedBox(
                          width: 304,
                          child: _ProfileSidebar(
                            currentUser: user,
                            posts: posts,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile column ───────────────────────────────────────────────────────────

class _ProfileColumn extends ConsumerWidget {
  const _ProfileColumn({
    required this.profileState,
    required this.user,
    required this.followedIds,
    required this.userThoughts,
    required this.userPosts,
  });

  final ProfileState profileState;
  final UserModel user;
  final Set<String> followedIds;
  final List<ThoughtModel> userThoughts;
  final List<PostModel> userPosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Banner(state: profileState, currentUser: user, ref: ref),
        ),
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
                      onPressed: () =>
                          ref.read(authProvider.notifier).logout(),
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
                const SizedBox(height: 20),
                Text(
                  user.displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                onDelete: () => ref
                    .read(thoughtsProvider.notifier)
                    .removeThought(userThoughts[index].id),
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
                  Text('No posts yet', style: TextStyle(color: muted)),
            ),
          )
        else
          SliverList.separated(
            itemCount: userPosts.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (_, i) => PostCard(post: userPosts[i]),
          ),
      ],
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _ProfileSidebar extends ConsumerWidget {
  const _ProfileSidebar(
      {required this.currentUser, required this.posts});

  final UserModel currentUser;
  final List<PostModel> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedIds = ref.watch(followProvider);

    final suggested = posts
        .map((p) => p.author)
        .where(
            (a) => a.id != currentUser.id && !followedIds.contains(a.id))
        .fold<Map<String, UserModel>>({}, (m, u) => m..[u.id] = u)
        .values
        .take(5)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarCard(
            title: 'Who to Follow',
            icon: Icons.people_outline_rounded,
            child: suggested.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Follow more people to see suggestions here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Column(
                    children: [
                      ...suggested.map((u) => _SuggestedUserRow(
                            user: u,
                            isFollowing: followedIds.contains(u.id),
                            onTap: () => context.push('/user/${u.id}'),
                            onFollow: () => ref
                                .read(followProvider.notifier)
                                .toggle(u.id),
                          )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: TextButton(
                          onPressed: () => context.go('/search'),
                          child: Text(
                            'Show more people',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _SidebarCard(
            title: 'Messages',
            icon: Icons.chat_bubble_outline_rounded,
            child: _MessagesBody(),
          ),
        ],
      ),
    );
  }
}

class _SidebarCard extends StatelessWidget {
  const _SidebarCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      backgroundOpacity: 0.06,
      borderOpacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Icon(icon,
                    size: 17,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 7),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SuggestedUserRow extends StatelessWidget {
  const _SuggestedUserRow({
    required this.user,
    required this.isFollowing,
    required this.onTap,
    required this.onFollow,
  });

  final UserModel user;
  final bool isFollowing;
  final VoidCallback onTap;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.white.withValues(alpha: 0.04),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(user: user, radius: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${user.username}',
                    style: TextStyle(color: muted, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _FollowChip(isFollowing: isFollowing, onTap: onFollow),
          ],
        ),
      ),
    );
  }
}

class _FollowChip extends StatefulWidget {
  const _FollowChip({required this.isFollowing, required this.onTap});
  final bool isFollowing;
  final VoidCallback onTap;

  @override
  State<_FollowChip> createState() => _FollowChipState();
}

class _FollowChipState extends State<_FollowChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isUnfollowHover = widget.isFollowing && _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isFollowing
                ? Colors.transparent
                : _hovered
                    ? primary.withValues(alpha: 0.85)
                    : primary,
            border: Border.all(
              color: isUnfollowHover
                  ? Colors.red.withValues(alpha: 0.6)
                  : widget.isFollowing
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            isUnfollowHover
                ? 'Unfollow'
                : widget.isFollowing
                    ? 'Following'
                    : 'Follow',
            style: TextStyle(
              color: isUnfollowHover ? Colors.red : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagesBody extends StatelessWidget {
  const _MessagesBody();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              children: [
                Icon(Icons.forum_outlined, size: 30, color: muted),
                const SizedBox(height: 8),
                const Text(
                  'No messages yet',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a conversation with\nsomeone you follow.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: muted, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('New Message',
                  style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(
                    color:
                        colorScheme.primary.withValues(alpha: 0.5)),
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner ───────────────────────────────────────────────────────────────────

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
          child: _AvatarDisplay(
            state: state,
            currentUser: state.user,
            onCreateThought: () => showDialog(
              context: context,
              builder: (ctx) =>
                  CreateThoughtDialog(currentUser: state.user),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Avatar display ───────────────────────────────────────────────────────────

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
              backgroundColor:
                  avatarColorFor(widget.state.user.displayName),
              backgroundImage: image,
              child: image == null
                  ? Text(
                      widget.state.user.displayName.isNotEmpty
                          ? widget.state.user.displayName[0]
                              .toUpperCase()
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onCreateThought,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.add, color: Colors.white, size: 20),
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

// ─── Follow stat ──────────────────────────────────────────────────────────────

class _FollowStat extends StatelessWidget {
  const _FollowStat(
      {required this.count, required this.label, this.onTap});
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          TextSpan(
              text: ' $label', style: TextStyle(color: muted)),
        ],
      ),
    );
    if (onTap == null) return text;
    return GestureDetector(onTap: onTap, child: text);
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'feed_providers.dart';
import 'widgets/post_card.dart';
import 'thought_card.dart';
import 'thoughts_providers.dart';
import 'create_thought_dialog.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/follow_providers.dart';
import '../../../models/thought_model.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/user_avatar.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedProvider);
    final thoughts = ref.watch(activeThoughtsProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: const Color(0xFF080A1C).withValues(alpha: 0.65),
              title: const Text('Home'),
              leadingWidth: 68,
              leading: user != null &&
                      MediaQuery.of(context).size.width < 650
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: _ThoughtBubbleButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => CreateThoughtDialog(currentUser: user),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                final feedCol = _FeedColumn(
                  posts: posts,
                  thoughts: thoughts,
                  userId: user?.id,
                  onDeleteThought: (id) =>
                      ref.read(thoughtsProvider.notifier).removeThought(id),
                );

                if (!isWide) return feedCol;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: feedCol),
                        const VerticalDivider(width: 1, thickness: 0.5),
                        SizedBox(
                          width: 304,
                          child: _Sidebar(currentUser: user, posts: posts),
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

// ─── Feed column ─────────────────────────────────────────────────────────────

class _FeedColumn extends StatelessWidget {
  const _FeedColumn({
    required this.posts,
    required this.thoughts,
    required this.userId,
    required this.onDeleteThought,
  });

  final List<PostModel> posts;
  final List<ThoughtModel> thoughts;
  final String? userId;
  final void Function(String id) onDeleteThought;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (thoughts.isNotEmpty) ...[
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: thoughts.length,
              itemBuilder: (context, index) {
                final t = thoughts[index];
                return ThoughtCard(
                  thought: t,
                  onDelete: t.author.id == userId
                      ? () => onDeleteThought(t.id)
                      : null,
                );
              },
            ),
          ),
          const Divider(),
        ],
        Expanded(
          child: posts.isEmpty
              ? Center(
                  child: Text(
                    'No posts yet — be the first!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) => PostCard(post: posts[i]),
                ),
        ),
      ],
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.currentUser, required this.posts});

  final UserModel? currentUser;
  final List<PostModel> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedIds = ref.watch(followProvider);

    final suggested = posts
        .map((p) => p.author)
        .where((a) => a.id != currentUser?.id && !followedIds.contains(a.id))
        .fold<Map<String, UserModel>>({}, (m, u) => m..[u.id] = u)
        .values
        .take(5)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WhoToFollowCard(suggested: suggested),
          const SizedBox(height: 16),
          const _MessagesCard(),
        ],
      ),
    );
  }
}

// ─── Who to Follow card ───────────────────────────────────────────────────────

class _WhoToFollowCard extends ConsumerWidget {
  const _WhoToFollowCard({required this.suggested});
  final List<UserModel> suggested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedIds = ref.watch(followProvider);

    return GlassContainer(
      borderRadius: 18,
      backgroundOpacity: 0.06,
      borderOpacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SidebarHeader(
            title: 'Who to Follow',
            icon: Icons.people_outline_rounded,
          ),
          if (suggested.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Follow more people to see suggestions here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else ...[
            ...suggested.map((u) => _SuggestedUserRow(
                  user: u,
                  isFollowing: followedIds.contains(u.id),
                  onTap: () => context.push('/user/${u.id}'),
                  onFollow: () =>
                      ref.read(followProvider.notifier).toggle(u.id),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TextButton(
                onPressed: () => context.go('/search'),
                child: Text(
                  'Show more people',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

// ─── Messages card ─────────────────────────────────────────────────────────────

class _MessagesCard extends StatelessWidget {
  const _MessagesCard();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassContainer(
      borderRadius: 18,
      backgroundOpacity: 0.06,
      borderOpacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SidebarHeader(
            title: 'Messages',
            icon: Icons.chat_bubble_outline_rounded,
          ),
          Padding(
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
                        style: TextStyle(color: muted, fontSize: 12, height: 1.4),
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
                          color: colorScheme.primary.withValues(alpha: 0.5)),
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared sidebar header ────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Icon(icon, size: 17,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 7),
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Thought bubble button ────────────────────────────────────────────────────

class _ThoughtBubbleButton extends StatelessWidget {
  const _ThoughtBubbleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _BubblePainter(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color backgroundColor;
  _BubblePainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.75),
        const Radius.circular(12),
      ))
      ..moveTo(12, size.height * 0.75)
      ..lineTo(8, size.height)
      ..lineTo(16, size.height * 0.75)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.backgroundColor != backgroundColor;
}

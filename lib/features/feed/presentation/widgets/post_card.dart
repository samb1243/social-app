import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../models/post_model.dart';
import '../../../../shared/widgets/post_video_player.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../feed_providers.dart';

class PostCard extends ConsumerStatefulWidget {
  const PostCard({super.key, required this.post, this.isReply = false, this.depth = 0});

  final PostModel post;
  final bool isReply;
  final int depth;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _repliesExpanded = true;
  bool _hovered = false;

  void _navigateToAuthor(BuildContext context) {
    final currentUserId = ref.read(authProvider)?.id;
    if (widget.post.author.id == currentUserId) {
      context.go('/profile');
    } else {
      context.push('/user/${widget.post.author.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final posts = ref.watch(feedProvider);
    final replies = posts.where((p) => p.replyToId == widget.post.id).toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: !widget.isReply ? () => context.push('/post/${widget.post.id}') : null,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: widget.depth > 0 ? 0.0 : (_hovered ? 0.05 : 0.025),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16 + widget.depth * 12.0,
              right: 16,
              top: 14,
              bottom: widget.isReply ? 10 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToAuthor(context),
                      child: UserAvatar(user: widget.post.author),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToAuthor(context),
                            child: Row(
                              children: [
                                Text(
                                  widget.post.author.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '@${widget.post.author.username}',
                                    style: TextStyle(color: muted, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('·', style: TextStyle(color: muted, fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  timeago.format(widget.post.createdAt, allowFromNow: true),
                                  style: TextStyle(color: muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (widget.post.content.isNotEmpty)
                            Text(
                              widget.post.content,
                              style: const TextStyle(fontSize: 15, height: 1.45),
                            ),
                          if (widget.post.imageBytes != null) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                widget.post.imageBytes!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ] else if (widget.post.videoMetadata != null) ...[
                            const SizedBox(height: 10),
                            PostVideoPlayer(metadata: widget.post.videoMetadata!),
                          ],
                          const SizedBox(height: 12),
                          _ActionRow(post: widget.post),
                          if (replies.isNotEmpty && !widget.isReply) ...[
                            const SizedBox(height: 8),
                            _RepliesToggle(
                              count: replies.length,
                              expanded: _repliesExpanded,
                              muted: muted,
                              onTap: () => setState(() => _repliesExpanded = !_repliesExpanded),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (replies.isNotEmpty && _repliesExpanded && !widget.isReply) ...[
                  const SizedBox(height: 10),
                  ...replies.map((reply) => PostCard(
                    post: reply,
                    isReply: true,
                    depth: widget.depth + 1,
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RepliesToggle extends StatefulWidget {
  const _RepliesToggle({
    required this.count,
    required this.expanded,
    required this.muted,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final Color? muted;
  final VoidCallback onTap;

  @override
  State<_RepliesToggle> createState() => _RepliesToggleState();
}

class _RepliesToggleState extends State<_RepliesToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovered
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
        : widget.muted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _hovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 3),
              Text(
                '${widget.count} ${widget.count == 1 ? 'reply' : 'replies'}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.post});
  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;

    return Row(
      children: [
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          count: post.repliesCount,
          color: muted,
          activeColor: const Color(0xFF60A5FA),
          active: false,
          onTap: () => context.push('/compose?replyTo=${post.id}'),
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: Icons.repeat_rounded,
          count: post.repostsCount,
          color: muted,
          activeColor: const Color(0xFF34D399),
          active: post.isReposted,
          onTap: () async =>
              ref.read(feedProvider.notifier).toggleRepost(post.id),
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: post.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          count: post.likesCount,
          color: muted,
          activeColor: const Color(0xFFF87171),
          active: post.isLiked,
          onTap: () async =>
              ref.read(feedProvider.notifier).toggleLike(post.id),
        ),
        const Spacer(),
        _ShareButton(muted: muted),
      ],
    );
  }
}

class _ShareButton extends StatefulWidget {
  const _ShareButton({required this.muted});
  final Color? muted;

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Icon(
          Icons.share_outlined,
          size: 17,
          color: _hovered
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
              : widget.muted,
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.activeColor,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final Color? color;
  final Color activeColor;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.active
        ? widget.activeColor
        : _hovered
            ? widget.activeColor
            : widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _hovered
                ? widget.activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _hovered ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: Icon(widget.icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 4),
              Text(
                _fmt(widget.count),
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

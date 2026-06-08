import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../models/post_model.dart';
import '../../../../shared/widgets/post_video_player.dart';
import '../../../../shared/widgets/user_avatar.dart';
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

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final posts = ref.watch(feedProvider);
    final replies = posts.where((p) => p.replyToId == widget.post.id).toList();

    return InkWell(
      onTap: !widget.isReply ? () => context.push('/post/${widget.post.id}') : null,
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.depth * 12.0,
          right: 16,
          top: 12,
          bottom: widget.isReply ? 8 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: UserAvatar(user: widget.post.author),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.post.author.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Text('@${widget.post.author.username}',
                              style: TextStyle(color: muted)),
                          const SizedBox(width: 4),
                          Text('·', style: TextStyle(color: muted)),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(widget.post.createdAt, allowFromNow: true),
                            style: TextStyle(color: muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.post.content.isNotEmpty)
                        Text(widget.post.content,
                            style: const TextStyle(fontSize: 15)),
                      if (widget.post.imageBytes != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(widget.post.imageBytes!,
                              width: double.infinity, fit: BoxFit.cover),
                        ),
                      ] else if (widget.post.videoMetadata != null) ...[
                        const SizedBox(height: 10),
                        PostVideoPlayer(metadata: widget.post.videoMetadata!),
                      ],
                      const SizedBox(height: 10),
                      _ActionRow(post: widget.post),
                      // Show reply count if there are replies
                      if (replies.isNotEmpty && !widget.isReply) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _repliesExpanded = !_repliesExpanded),
                          child: Row(
                            children: [
                              Icon(
                                _repliesExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 18,
                                color: muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // Nested replies
            if (replies.isNotEmpty && _repliesExpanded && !widget.isReply) ...[
              const SizedBox(height: 12),
              ...replies.map((reply) => PostCard(
                post: reply,
                isReply: true,
                depth: widget.depth + 1,
              )),
            ],
          ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          count: post.repliesCount,
          color: muted,
          onTap: () => context.push('/compose?replyTo=${post.id}'),
        ),
        _ActionButton(
          icon: Icons.repeat,
          count: post.repostsCount,
          color: post.isReposted ? Colors.green : muted,
          onTap: () async =>
              ref.read(feedProvider.notifier).toggleRepost(post.id),
        ),
        _ActionButton(
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          count: post.likesCount,
          color: post.isLiked ? Colors.red : muted,
          onTap: () async =>
              ref.read(feedProvider.notifier).toggleLike(post.id),
        ),
        Icon(Icons.share_outlined, size: 18, color: muted),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(_fmt(count), style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

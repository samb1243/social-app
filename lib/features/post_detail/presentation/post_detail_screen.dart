import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/post_model.dart';
import '../../../shared/widgets/post_video_player.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../feed/presentation/feed_providers.dart';
import '../../feed/presentation/widgets/post_card.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(feedProvider);
    final post = posts.where((p) => p.id == postId).firstOrNull;

    if (post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Post not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _DetailHeader(post: post),
          const Divider(),
          PostCard(post: post),
        ],
      ),
    );
  }
}

class _DetailHeader extends ConsumerWidget {
  const _DetailHeader({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    final fmt = DateFormat('h:mm a · MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(user: post.author, radius: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.author.displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('@${post.author.username}',
                      style: TextStyle(color: muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (post.content.isNotEmpty)
            Text(post.content, style: const TextStyle(fontSize: 18)),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(post.imageUrl!,
                  width: double.infinity, fit: BoxFit.cover),
            ),
          ] else if (post.imageBytes != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(post.imageBytes!,
                  width: double.infinity, fit: BoxFit.cover),
            ),
          ] else if (post.videoMetadata != null) ...[
            const SizedBox(height: 12),
            PostVideoPlayer(metadata: post.videoMetadata!),
          ],
          const SizedBox(height: 12),
          Text(fmt.format(post.createdAt),
              style: TextStyle(color: muted, fontSize: 13)),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(count: post.repostsCount, label: 'Reposts'),
              const SizedBox(width: 20),
              _Stat(count: post.repliesCount, label: 'Replies'),
              const SizedBox(width: 20),
              _Stat(count: post.likesCount, label: 'Likes'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {},
                color: muted,
              ),
              IconButton(
                icon: const Icon(Icons.repeat),
                color: post.isReposted ? Colors.green : muted,
                onPressed: () async =>
                    ref.read(feedProvider.notifier).toggleRepost(post.id),
              ),
              IconButton(
                icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border),
                color: post.isLiked ? Colors.red : muted,
                onPressed: () async =>
                    ref.read(feedProvider.notifier).toggleLike(post.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
                color: muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$count',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          TextSpan(
              text: ' $label',
              style: TextStyle(color: muted, fontSize: 14)),
        ],
      ),
    );
  }
}

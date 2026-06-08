import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../feed/presentation/feed_providers.dart';
import '../../feed/presentation/widgets/post_card.dart';
import '../../../models/post_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(feedProvider);
    final results = _query.isEmpty
        ? <PostModel>[]
        : allPosts
            .where((p) =>
                p.content.toLowerCase().contains(_query.toLowerCase()) ||
                p.author.username
                    .toLowerCase()
                    .contains(_query.toLowerCase()) ||
                p.author.displayName
                    .toLowerCase()
                    .contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search posts',
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Search for posts or people'))
          : results.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) => PostCard(post: results[i]),
                ),
    );
  }
}

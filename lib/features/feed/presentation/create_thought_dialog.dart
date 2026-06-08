import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import 'thoughts_providers.dart';

const int _maxThoughtLength = 280;

class CreateThoughtDialog extends ConsumerStatefulWidget {
  final UserModel currentUser;

  const CreateThoughtDialog({
    super.key,
    required this.currentUser,
  });

  @override
  ConsumerState<CreateThoughtDialog> createState() =>
      _CreateThoughtDialogState();
}

class _CreateThoughtDialogState extends ConsumerState<CreateThoughtDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitThought() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    ref.read(thoughtsProvider.notifier).addThought(
          content,
          widget.currentUser,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thought posted! Expires in 24 hours')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textLength = _controller.text.length;
    final isOverLimit = textLength > _maxThoughtLength;

    return AlertDialog(
      title: const Text('What\'s on your mind?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: _maxThoughtLength,
            decoration: InputDecoration(
              hintText: 'Share a thought (expires in 24h)...',
              border: const OutlineInputBorder(),
              counterText: '$textLength/$_maxThoughtLength',
              counterStyle: TextStyle(
                color: isOverLimit ? Colors.red : null,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            'Thoughts automatically disappear after 24 hours',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isOverLimit || _controller.text.trim().isEmpty
              ? null
              : _submitThought,
          child: const Text('Post'),
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/thought_model.dart';
import '../../../models/user_model.dart';

class ThoughtsNotifier extends StateNotifier<List<ThoughtModel>> {
  ThoughtsNotifier() : super([]);

  void addThought(String content, UserModel author) {
    final now = DateTime.now();
    final thought = ThoughtModel(
      id: const Uuid().v4(),
      author: author,
      content: content,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
    state = [thought, ...state];
  }

  void removeThought(String thoughtId) {
    state = state.where((t) => t.id != thoughtId).toList();
  }

  void removeExpiredThoughts() {
    state = state.where((t) => !t.isExpired).toList();
  }

  List<ThoughtModel> getActiveThoughts() {
    removeExpiredThoughts();
    return state;
  }

  List<ThoughtModel> getUserThoughts(String userId) {
    final active = getActiveThoughts();
    return active.where((t) => t.author.id == userId).toList();
  }
}

final thoughtsProvider =
    StateNotifierProvider<ThoughtsNotifier, List<ThoughtModel>>((ref) {
  return ThoughtsNotifier();
});

final activeThoughtsProvider = Provider<List<ThoughtModel>>((ref) {
  final thoughts = ref.watch(thoughtsProvider);
  return thoughts.where((t) => !t.isExpired).toList();
});

final userThoughtsProvider = FutureProvider.family<List<ThoughtModel>, String>(
  (ref, userId) async {
    final thoughts = ref.watch(activeThoughtsProvider);
    return thoughts.where((t) => t.author.id == userId).toList();
  },
);

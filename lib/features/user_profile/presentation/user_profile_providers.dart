import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/mock_data.dart';
import '../../../models/user_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../feed/presentation/feed_providers.dart';

/// Map of user ID → UserModel built from mock users, every post's embedded
/// author, and the currently logged-in user.  This ensures any author whose
/// post is visible in the feed can always be looked up by ID.
final allUsersProvider = Provider<Map<String, UserModel>>((ref) {
  final currentUser = ref.watch(authProvider);
  final posts = ref.watch(feedProvider);

  final map = <String, UserModel>{
    for (final u in mockUsers) u.id: u,
    for (final p in posts) p.author.id: p.author,
  };
  if (currentUser != null) map[currentUser.id] = currentUser;
  return map;
});

/// Look up a single user by ID, returning null if not found.
final userByIdProvider = Provider.family<UserModel?, String>((ref, id) {
  return ref.watch(allUsersProvider)[id];
});

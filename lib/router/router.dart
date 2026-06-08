/// Router configuration for the application.
/// 
/// This file sets up GoRouter with:
/// - Route definitions (login, feed, search, etc.)
/// - Auth-based redirect logic (redirects to login if not authenticated)
/// - Protected routes that require authentication
/// - Shell route for main app navigation (feed, search, profile, notifications)
/// - Post detail and compose routes
/// 
/// The router automatically redirects users based on authentication state
/// and listens for auth changes to update the navigation.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/feed/presentation/feed_screen.dart';
import '../features/post_detail/presentation/post_detail_screen.dart';
import '../features/create_post/presentation/create_post_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/follow_list_screen.dart';
import '../features/user_profile/presentation/user_profile_screen.dart';
import '../shared/widgets/shell_scaffold.dart';

/// Internal notifier that rebuilds the router when auth state changes.
/// This allows GoRouter to react to login/logout events.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    // Listen to auth changes and notify listeners to rebuild the router
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

/// Provider that creates and manages the GoRouter instance.
/// 
/// This router:
/// - Redirects unauthenticated users to /login
/// - Redirects authenticated users away from auth routes back to /feed
/// - Provides navigation between all app screens
final routerProvider = Provider<GoRouter>((ref) {
  // Create notifier to listen for auth changes
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    // Default route when app starts
    initialLocation: '/login',
    // Rebuild router when auth state changes
    refreshListenable: notifier,
    // Redirect logic based on authentication status
    redirect: (context, state) {
      // Check if user is logged in
      final isLoggedIn = ref.read(authProvider) != null;
      // Get current route path
      final loc = state.matchedLocation;
      // Check if current route is an auth route
      final isAuthRoute = loc == '/login' || loc == '/register';

      // Redirect to login if not authenticated and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) return '/login';
      // Redirect to feed if already logged in and trying to access auth routes
      if (isLoggedIn && isAuthRoute) return '/feed';
      // No redirect needed
      return null;
    },
    // Define all routes in the app
    routes: [
      // Auth routes - accessible when not logged in
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      
      // Shell route wraps all main app screens with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          // Feed screen - main timeline
          GoRoute(
            path: '/feed',
            pageBuilder: (_, _) => const NoTransitionPage(child: FeedScreen()),
          ),
          // Search screen - search for posts and users
          GoRoute(
            path: '/search',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          // Notifications screen - shows user notifications
          GoRoute(
            path: '/notifications',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: NotificationsScreen()),
          ),
          // User profile screen - shows current user's profile
          GoRoute(
            path: '/profile',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      
      // Post detail screen - shows single post and replies (not in shell)
      GoRoute(
        path: '/post/:id',
        builder: (context, state) =>
            PostDetailScreen(postId: state.pathParameters['id']!),
      ),
      
      // Compose screen - create new post or reply (not in shell)
      GoRoute(
        path: '/compose',
        builder: (context, state) =>
            CreatePostScreen(replyToId: state.uri.queryParameters['replyTo']),
      ),
      
      // Edit profile screen - edit user profile (not in shell)
      GoRoute(
        path: '/edit-profile',
        builder: (_, _) => const EditProfileScreen(),
      ),

      // Other user profile screen - view any user's profile by ID
      GoRoute(
        path: '/user/:id',
        builder: (context, state) =>
            UserProfileScreen(userId: state.pathParameters['id']!),
      ),

      // Followers / following list for any user
      GoRoute(
        path: '/follow-list',
        builder: (context, state) => FollowListScreen(
          userId: state.uri.queryParameters['userId']!,
          mode: state.uri.queryParameters['mode']!,
        ),
      ),
    ],
  );
});

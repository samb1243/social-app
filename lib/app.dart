/// Root widget of the application.
/// 
/// The App widget:
/// - Initializes authentication state on startup
/// - Initializes the feed with posts for the current user
/// - Configures the router based on authentication status
/// - Sets up Material Design theme (light/dark/system)
/// - Uses GoRouter for navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/glass_container.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Social',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppBackground(child: child),
    );
  }
}

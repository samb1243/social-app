/// Entry point of the application.
/// 
/// This file initializes the Flutter app with Riverpod's ProviderScope,
/// which enables state management and dependency injection throughout the app.
/// 
/// The ProviderScope wraps the entire app to provide access to Riverpod providers
/// at any widget in the widget tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Main function - the entry point of the application.
void main() {
  // ProviderScope wraps the entire app to enable Riverpod state management
  runApp(const ProviderScope(child: App()));
}

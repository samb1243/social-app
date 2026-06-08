/// Platform-aware export for auth storage.
/// 
/// This file uses conditional compilation to export the correct implementation:
/// - On native platforms (iOS, Android): exports auth_storage_native.dart (uses dart:io for file I/O)
/// - On web platform: exports auth_storage_web.dart (uses in-memory storage)
/// 
/// This allows the same code to work across platforms with platform-specific implementations
/// without needing to use different imports in the rest of the app.
library;

// Conditional export: native platforms use dart:io file I/O, web uses in-memory.
export 'auth_storage_web.dart' if (dart.library.io) 'auth_storage_native.dart';

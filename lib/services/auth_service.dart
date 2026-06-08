/// Authentication service for managing user accounts.
/// 
/// Provides methods to:
/// - Load saved user accounts from storage
/// - Save new/updated user accounts
/// 
/// The actual storage implementation depends on the platform:
/// - Web: uses in-memory storage (auth_storage_web.dart)
/// - Native (iOS/Android): uses file-based storage (auth_storage_native.dart)
/// 
/// This service bridges the platform-specific implementations.
library;

import 'auth_storage.dart';

/// Represents a stored user account with credentials.
/// 
/// WARNING: In production, passwords should NEVER be stored in plain text.
/// This is for demonstration purposes only.
class AccountRecord {
  // Unique user ID
  final String id;
  // User's display name
  final String displayName;
  // User's unique username
  final String username;
  // User's email address
  final String email;
  // User's password (STORED IN PLAIN TEXT - NOT FOR PRODUCTION)
  final String password;

  const AccountRecord({
    required this.id,
    required this.displayName,
    required this.username,
    required this.email,
    required this.password,
  });

  /// Converts account to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'username': username,
        'email': email,
        'password': password,
      };

  /// Creates AccountRecord from JSON
  factory AccountRecord.fromJson(Map<String, dynamic> json) => AccountRecord(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );
}

/// Main authentication service
/// 
/// This service handles account persistence across app launches.
/// It delegates to platform-specific implementations for actual storage.
class AuthService {
  /// Loads all saved user accounts from storage
  static Future<List<AccountRecord>> loadAccounts() async {
    // Load raw JSON data from platform-specific storage
    final raw = await loadRawAccounts();
    // Convert JSON to AccountRecord objects
    return raw.map(AccountRecord.fromJson).toList();
  }

  /// Saves user accounts to storage
  static Future<void> saveAccounts(List<AccountRecord> accounts) async {
    // Convert AccountRecords to JSON and save to platform-specific storage
    await saveRawAccounts(accounts.map((a) => a.toJson()).toList());
  }
}

/// Authentication state management using Riverpod.
/// 
/// This provider manages:
/// - User login/logout
/// - User registration
/// - Loading/saving accounts to persistent storage
/// - Admin login (for testing)
/// 
/// The state is a nullable UserModel - null means logged out.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

/// Manages authentication state and user session.
/// 
/// Handles login, registration, and logout operations.
/// Persists auth data to device storage so user stays logged in between sessions.
class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  /// Logs in a user with email and password.
  /// 
  /// Returns an error message if login fails (bad credentials, etc.), null on success.
  /// Case-insensitive email matching, case-sensitive password.
  /// Sets the state to the logged-in user on success.
  Future<String?> login(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    // Load all registered accounts
    final accounts = await AuthService.loadAccounts();
    // Find matching account by email and password
    final match = accounts
        .where((a) =>
            a.email.toLowerCase() == trimmedEmail && a.password == password)
        .firstOrNull;
    // Return error if no match found
    if (match == null) return 'Incorrect email or password.';
    // Set logged-in user as state
    state = UserModel(
      id: match.id,
      username: match.username,
      displayName: match.displayName,
    );
    return null;
  }

  /// Admin login without password (for testing/demo only).
  /// 
  /// Logs in with admin account or creates one if it doesn't exist.
  /// DO NOT USE IN PRODUCTION - This bypasses security!
  Future<String?> loginAdmin() async {
    final accounts = await AuthService.loadAccounts();
    
    // Try to find existing admin account
    final adminMatch = accounts
        .where((a) => a.username.toLowerCase() == 'admin')
        .firstOrNull;
    
    if (adminMatch != null) {
      state = UserModel(
        id: adminMatch.id,
        username: adminMatch.username,
        displayName: adminMatch.displayName,
      );
      return null;
    }

    // Create a new admin account if it doesn't exist
    final adminRecord = AccountRecord(
      id: 'admin',
      displayName: 'Administrator',
      username: 'admin',
      email: 'admin@test.local',
      password: 'admin',
    );
    
    // Save admin account
    await AuthService.saveAccounts([...accounts, adminRecord]);
    // Log in as admin
    state = UserModel(
      id: adminRecord.id,
      username: adminRecord.username,
      displayName: adminRecord.displayName,
    );
    return null;
  }

  /// Admin 2 login without password (for testing/demo only).
  Future<String?> loginAdmin2() async {
    final accounts = await AuthService.loadAccounts();

    final match = accounts
        .where((a) => a.username.toLowerCase() == 'nova')
        .firstOrNull;

    if (match != null) {
      state = UserModel(
        id: match.id,
        username: match.username,
        displayName: match.displayName,
      );
      return null;
    }

    final record = AccountRecord(
      id: 'admin2',
      displayName: 'Nova Rivera',
      username: 'nova',
      email: 'nova@test.local',
      password: 'admin2',
    );

    await AuthService.saveAccounts([...accounts, record]);
    state = UserModel(
      id: record.id,
      username: record.username,
      displayName: record.displayName,
    );
    return null;
  }

  /// Registers a new user account.
  /// 
  /// Validates that email and username are not already taken.
  /// Returns an error message if validation fails, null on success.
  /// Automatically logs in the user after successful registration.
  Future<String?> register({
    required String displayName,
    required String username,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedUsername = username.trim().toLowerCase();
    // Load existing accounts for validation
    final accounts = await AuthService.loadAccounts();

    // Check if email already exists
    if (accounts.any((a) => a.email.toLowerCase() == trimmedEmail)) {
      return 'An account with that email already exists.';
    }
    // Check if username already exists
    if (accounts.any((a) => a.username.toLowerCase() == trimmedUsername)) {
      return 'That username is already taken.';
    }

    // Create new account record
    final record = AccountRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: displayName.trim(),
      username: username.trim(),
      email: email.trim(),
      password: password,
    );
    // Save new account to storage
    await AuthService.saveAccounts([...accounts, record]);
    // Log in the newly registered user
    state = UserModel(
      id: record.id,
      username: record.username,
      displayName: record.displayName,
    );
    return null;
  }

  /// Logs out the current user.
  /// Sets state to null to indicate no active session.
  void logout() => state = null;
}

/// Riverpod provider for authentication state.
/// 
/// Access with: ref.watch(authProvider) to get current user or null if logged out.
/// Use ref.read(authProvider.notifier) to call login/register/logout.
final authProvider = NotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
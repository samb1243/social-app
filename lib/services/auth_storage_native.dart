/// Native implementation of auth storage (iOS, Android, Windows, Linux, macOS).
/// 
/// Uses the device's file system via dart:io to persist accounts between app sessions.
/// Accounts are stored in the app's documents directory as a JSON file.
library;

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Gets the file path where accounts are stored.
/// 
/// Returns a File object pointing to social_app_accounts.json in the app's
/// documents directory (location varies by platform).
Future<File> _accountsFile() async {
  // Get the app's documents directory (platform-specific)
  final dir = await getApplicationDocumentsDirectory();
  // Return File object for our accounts JSON file
  return File('${dir.path}/social_app_accounts.json');
}

/// Loads accounts from the file system.
/// 
/// Returns an empty list if the file doesn't exist yet.
/// Catches any errors and returns empty list gracefully.
Future<List<Map<String, dynamic>>> loadRawAccounts() async {
  try {
    final file = await _accountsFile();
    // Return empty list if file doesn't exist
    if (!await file.exists()) return [];
    // Read file contents and decode JSON
    final content = await file.readAsString();
    // Parse JSON and cast to list of maps
    return (jsonDecode(content) as List).cast<Map<String, dynamic>>();
  } catch (_) {
    // Return empty list on any error (file corrupt, permission issues, etc.)
    return [];
  }
}

/// Saves accounts to the file system.
/// 
/// Encodes the account list as JSON and writes to the accounts file.
/// Creates the file if it doesn't exist.
Future<void> saveRawAccounts(List<Map<String, dynamic>> accounts) async {
  final file = await _accountsFile();
  // Encode list to JSON and write to file
  await file.writeAsString(jsonEncode(accounts));
}

/// Web implementation of auth storage.
/// 
/// On the web platform (where dart:io file access is not available),
/// this uses an in-memory list to store accounts.
/// 
/// NOTE: Data will be lost when the browser tab is closed or refreshed.
/// For production web apps, use browser APIs like IndexedDB or LocalStorage.
library;

// In-memory store used on web (no dart:io file access available).
// This list persists for the duration of the page load.
final List<Map<String, dynamic>> _store = [];

/// Loads all saved accounts from memory.
/// 
/// On web, returns the in-memory list. Data is lost on page refresh.
Future<List<Map<String, dynamic>>> loadRawAccounts() async => 
  List.from(_store);

/// Saves accounts to memory.
/// 
/// Clears existing data and replaces with new accounts.
Future<void> saveRawAccounts(List<Map<String, dynamic>> accounts) async {
  _store
    ..clear()
    ..addAll(accounts);
}

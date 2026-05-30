import 'offline_sync_row.dart';

/// Stub implementation of AppDatabase for web platform.
/// On web, offline sync is not persisted to avoid complexity with browser storage.
class AppDatabase {
  AppDatabase({dynamic encryptionService});

  /// Indicates whether an encryption key exists (always false on web)
  Future<bool> isEncrypted() async {
    return false;
  }

  /// Create offline_sync table if it doesn't exist (no-op on web)
  Future<void> ensureOfflineSyncTable() async {
    // No-op: web doesn't persist offline queue
  }

  /// Upsert an offline sync operation (no-op on web, return the ID)
  Future<String> upsertOfflineSyncOperation({
    required String id,
    required String method,
    required String url,
    required String headersJson,
    String? bodyJson,
    required String createdAtIso,
    required String fingerprint,
  }) async {
    // Web doesn't persist, just return the ID
    return id;
  }

  /// Get pending offline sync queue (always empty on web)
  Future<List<OfflineSyncDbRow>> getPendingOfflineSyncQueue({
    int limit = 200,
  }) async {
    return [];
  }

  /// Get pending offline sync count (always 0 on web)
  Future<int> getPendingOfflineSyncCount() async {
    return 0;
  }

  /// Get a specific offline sync row by ID (always null on web)
  Future<OfflineSyncDbRow?> getOfflineSyncById(String id) async {
    return null;
  }

  /// Mark an offline sync as syncing (no-op on web)
  Future<void> markOfflineSyncAsSyncing(String id) async {
    // No-op on web
  }

  /// Mark an offline sync as failed (no-op on web)
  Future<void> markOfflineSyncAsFailed({
    required String id,
    required String errorMessage,
  }) async {
    // No-op on web
  }

  /// Delete an offline sync row by ID (no-op on web)
  Future<void> deleteOfflineSyncById(String id) async {
    // No-op on web
  }

  /// Close the database connection (no-op on web)
  Future<void> closeDb() async {
    // No-op on web
  }
}

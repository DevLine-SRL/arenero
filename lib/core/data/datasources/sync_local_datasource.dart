import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/app_database.dart';
import '../../models/sync_status.dart';

enum OutboxOperationType {
  createClient('create_client'),
  registerSale('register_sale');

  final String dbValue;

  const OutboxOperationType(this.dbValue);

  static OutboxOperationType fromDatabase(String value) {
    return OutboxOperationType.values.firstWhere(
      (operation) => operation.dbValue == value,
      orElse: () => throw ArgumentError('Operación desconocida: $value'),
    );
  }
}

class PendingOperation {
  final int id;
  final OutboxOperationType operation;
  final Map<String, dynamic> payload;
  final int attempts;
  final String? lastError;

  const PendingOperation({
    required this.id,
    required this.operation,
    required this.payload,
    required this.attempts,
    this.lastError,
  });
}

abstract class SyncLocalDataSource {
  Future<void> enqueue({
    required OutboxOperationType operation,
    required Map<String, dynamic> payload,
  });

  Future<List<PendingOperation>> getPendingOperations();

  Future<void> markSynced(int operationId);

  Future<void> markFailed(int operationId, String error);

  Future<void> updatePayload(int operationId, Map<String, dynamic> payload);

  Future<int> countPending();

  Future<void> retryFailed();

  Future<String> getDeviceId();

  Future<DateTime?> getLastSyncAt();

  Future<void> setLastSyncAt(DateTime value);
}

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  final AppDatabase database;
  final String? Function() currentUserId;

  SyncLocalDataSourceImpl(this.database, {required this.currentUserId});

  static const String _deviceIdKey = 'device_id';
  static const String _lastSyncAtKey = 'last_sync_at';

  @override
  Future<void> enqueue({
    required OutboxOperationType operation,
    required Map<String, dynamic> payload,
  }) async {
    final userId = currentUserId();
    if (userId == null) return;

    await database
        .into(database.outboxOperations)
        .insert(
          OutboxOperationsCompanion.insert(
            operation: operation.dbValue,
            payload: jsonEncode(payload),
            status: SyncStatus.pending.dbValue,
            userId: Value(userId),
          ),
        );
  }

  @override
  Future<List<PendingOperation>> getPendingOperations() async {
    final userId = currentUserId();
    if (userId == null) return [];

    final rows =
        await (database.select(database.outboxOperations)
              ..where(
                (t) =>
                    t.userId.equals(userId) &
                    t.status.equals(SyncStatus.pending.dbValue),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();

    return [
      for (final row in rows)
        PendingOperation(
          id: row.id,
          operation: OutboxOperationType.fromDatabase(row.operation),
          payload: jsonDecode(row.payload) as Map<String, dynamic>,
          attempts: row.attempts,
          lastError: row.lastError,
        ),
    ];
  }

  @override
  Future<void> markSynced(int operationId) async {
    await (database.delete(
      database.outboxOperations,
    )..where((t) => t.id.equals(operationId))).go();
  }

  @override
  Future<void> markFailed(int operationId, String error) async {
    final row = await (database.select(
      database.outboxOperations,
    )..where((t) => t.id.equals(operationId))).getSingleOrNull();
    if (row == null) return;

    await (database.update(
      database.outboxOperations,
    )..where((t) => t.id.equals(operationId))).write(
      OutboxOperationsCompanion(
        status: Value(SyncStatus.error.dbValue),
        attempts: Value(row.attempts + 1),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updatePayload(
    int operationId,
    Map<String, dynamic> payload,
  ) async {
    await (database.update(
      database.outboxOperations,
    )..where((t) => t.id.equals(operationId))).write(
      OutboxOperationsCompanion(
        payload: Value(jsonEncode(payload)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> countPending() async {
    final userId = currentUserId();
    if (userId == null) return 0;

    final rows =
        await (database.select(database.outboxOperations)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.status.equals(SyncStatus.pending.dbValue),
            ))
            .get();
    return rows.length;
  }

  @override
  Future<void> retryFailed() async {
    final userId = currentUserId();
    if (userId == null) return;

    await (database.update(database.outboxOperations)..where(
          (t) =>
              t.userId.equals(userId) &
              t.status.equals(SyncStatus.error.dbValue),
        ))
        .write(
          OutboxOperationsCompanion(
            status: Value(SyncStatus.pending.dbValue),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<String> getDeviceId() async {
    final existing = await _readKey(_deviceIdKey);
    if (existing != null) return existing;

    final deviceId = const Uuid().v4();
    await _writeKey(_deviceIdKey, deviceId);
    return deviceId;
  }

  @override
  Future<DateTime?> getLastSyncAt() async {
    final raw = await _readKey(_lastSyncAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> setLastSyncAt(DateTime value) async {
    await _writeKey(_lastSyncAtKey, value.toIso8601String());
  }

  Future<String?> _readKey(String key) async {
    final row = await (database.select(
      database.syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeKey(String key, String value) async {
    await database
        .into(database.syncMeta)
        .insert(
          SyncMetaCompanion.insert(key: key, value: value),
          onConflict: DoUpdate((_) => SyncMetaCompanion(value: Value(value))),
        );
  }
}

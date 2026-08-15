import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/sync_status.dart';
import 'active_user_id_provider.dart';
import 'app_database_provider.dart';

part 'failed_operations_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<int> failedOperationsCount(Ref ref) {
  final userId = ref.watch(activeUserIdProvider);
  final database = ref.watch(appDatabaseProvider);

  if (userId == null) return Stream.value(0);

  final query =
      (database.select(database.outboxOperations)..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals(SyncStatus.error.dbValue),
          ))
          .watch();
  return query.map((rows) => rows.length);
}

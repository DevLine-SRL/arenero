import 'package:drift/drift.dart';

import '../../../../core/models/app_database.dart';
import '../../../../core/models/sync_status.dart';
import '../models/client_model.dart';

abstract class ClientsLocalDataSource {
  Future<void> upsertClients(
    List<ClientModel> clients, {
    SyncStatus syncStatus = SyncStatus.synced,
  });

  Future<List<ClientModel>> searchCachedClients({
    required String query,
    bool includeInactive = false,
  });

  Future<bool> existsByCi(String ci);

  Future<void> setActive(String id, bool active);
}

class ClientsLocalDataSourceImpl implements ClientsLocalDataSource {
  final AppDatabase database;

  const ClientsLocalDataSourceImpl(this.database);

  @override
  Future<void> upsertClients(
    List<ClientModel> clients, {
    SyncStatus syncStatus = SyncStatus.synced,
  }) async {
    await database.transaction(() async {
      final now = DateTime.now();
      await database.batch((batch) {
        for (final client in clients) {
          batch.insert(
            database.localClients,
            LocalClientsCompanion.insert(
              id: client.id,
              name: client.name,
              phone: Value(client.phone),
              ci: client.ci,
              nit: Value(client.nit),
              active: client.active,
              syncStatus: Value(syncStatus.dbValue),
              updatedAt: now,
            ),
            onConflict: DoUpdate(
              (_) => LocalClientsCompanion(
                name: Value(client.name),
                phone: Value(client.phone),
                ci: Value(client.ci),
                nit: Value(client.nit),
                active: Value(client.active),
                syncStatus: Value(syncStatus.dbValue),
                updatedAt: Value(now),
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Future<List<ClientModel>> searchCachedClients({
    required String query,
    bool includeInactive = false,
  }) async {
    final rows = await (database.select(
      database.localClients,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

    final term = _sanitizeSearchTerm(query).toLowerCase();
    return [
      for (final row in rows)
        if ((includeInactive || row.active) && _matches(row, term))
          ClientModel(
            id: row.id,
            name: row.name,
            phone: row.phone,
            ci: row.ci,
            nit: row.nit,
            active: row.active,
          ),
    ];
  }

  @override
  Future<bool> existsByCi(String ci) async {
    final row = await (database.select(
      database.localClients,
    )..where((t) => t.ci.equals(ci))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> setActive(String id, bool active) async {
    await (database.update(
      database.localClients,
    )..where((t) => t.id.equals(id))).write(
      LocalClientsCompanion(
        active: Value(active),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  bool _matches(LocalClient row, String term) {
    if (term.isEmpty) return true;
    return row.name.toLowerCase().contains(term) ||
        row.ci.toLowerCase().contains(term) ||
        (row.nit?.toLowerCase().contains(term) ?? false);
  }

  String _sanitizeSearchTerm(String query) {
    return query.trim().replaceAll(RegExp(r'[,%_()*"\\]'), '');
  }
}

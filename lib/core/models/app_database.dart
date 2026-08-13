import 'package:drift/drift.dart';

import '../../features/auth/data/models/profiles_table.dart';
import '../../features/clients/data/models/clients_table.dart';
import '../../features/products/data/models/products_tables.dart';
import '../../features/sales/data/models/sales_tables.dart';
import 'outbox_table.dart';
import 'sync_meta_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalClients,
    LocalProducts,
    LocalProductUnits,
    LocalProfiles,
    LocalSales,
    LocalSaleDetails,
    LocalSaleDeliveries,
    LocalSaleHistory,
    OutboxOperations,
    SyncMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _upgradeToV2(m);
      }
    },
  );

  Future<void> _upgradeToV2(Migrator m) async {
    await m.createAll();

    await _addColumnIfMissing(m, localClients, localClients.syncStatus);
    await _addColumnIfMissing(m, localClients, localClients.syncError);
    await _addColumnIfMissing(m, localSales, localSales.syncStatus);
    await _addColumnIfMissing(m, localSales, localSales.syncError);
    await _addColumnIfMissing(m, localSaleDetails, localSaleDetails.syncStatus);
    await _addColumnIfMissing(m, localSaleDetails, localSaleDetails.syncError);
    await _addColumnIfMissing(
      m,
      localSaleDeliveries,
      localSaleDeliveries.syncStatus,
    );
    await _addColumnIfMissing(
      m,
      localSaleDeliveries,
      localSaleDeliveries.syncError,
    );
  }

  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final hasColumn = rows.any(
      (row) => row.read<String>('name') == column.$name,
    );
    if (!hasColumn) {
      await m.addColumn(table, column);
    }
  }
}

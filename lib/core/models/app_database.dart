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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (!details.wasCreated) {
        await _createMissingTables();
      }
    },
  );

  Future<void> _createMissingTables() async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get();
    final present = {for (final row in rows) row.read<String>('name')};
    final complete = {
      'local_clients',
      'local_products',
      'local_product_units',
      'local_profiles',
      'local_sales',
      'local_sale_details',
      'local_sale_deliveries',
      'local_sale_history',
      'outbox_operations',
      'sync_meta',
    };
    if (!complete.every(present.contains)) {
      await createMigrator().createAll();
    }
  }
}

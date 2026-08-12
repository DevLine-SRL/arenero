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
        final hasProductUnits = await customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'local_product_units'",
        ).getSingleOrNull();
        if (hasProductUnits == null) {
          await createMigrator().createAll();
        }
      }
    },
  );
}

import 'package:drift/drift.dart';

import '../../../../core/models/app_database.dart';
import '../models/seller_model.dart';

abstract class SellersLocalDataSource {
  Future<void> replaceSellers(List<SellerModel> sellers);

  Future<List<SellerModel>> getCachedSellers();

  Future<void> setActive(String id, bool active);
}

class SellersLocalDataSourceImpl implements SellersLocalDataSource {
  final AppDatabase database;

  const SellersLocalDataSourceImpl(this.database);

  @override
  Future<void> replaceSellers(List<SellerModel> sellers) async {
    if (sellers.isEmpty) return;
    await database.transaction(() async {
      await (database.delete(
        database.localProfiles,
      )..where((t) => t.role.equals('seller'))).go();

      final now = DateTime.now();
      await database.batch((batch) {
        for (final seller in sellers) {
          batch.insert(
            database.localProfiles,
            LocalProfilesCompanion.insert(
              id: seller.id,
              email: seller.email,
              name: Value(seller.name),
              role: 'seller',
              active: seller.active,
              lastSeenAt: const Value(null),
              updatedAt: now,
            ),
          );
        }
      });
    });
  }

  @override
  Future<List<SellerModel>> getCachedSellers() async {
    final rows = await (database.select(
      database.localProfiles,
    )..where((t) => t.role.equals('seller'))).get();

    return [
      for (final row in rows)
        SellerModel(
          id: row.id,
          email: row.email,
          name: row.name,
          active: row.active,
        ),
    ];
  }

  @override
  Future<void> setActive(String id, bool active) async {
    await (database.update(
      database.localProfiles,
    )..where((t) => t.id.equals(id))).write(
      LocalProfilesCompanion(
        active: Value(active),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

import 'package:drift/drift.dart';

import '../../../../core/models/app_database.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class ProductsLocalDataSource {
  Future<void> replaceCatalog(List<ProductModel> products);

  Future<List<ProductModel>> getCachedProducts();

  Future<void> updateProductName({required String id, required String name});

  Future<void> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  });

  Future<void> setActive(String id, bool active);
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final AppDatabase database;

  const ProductsLocalDataSourceImpl(this.database);

  @override
  Future<void> replaceCatalog(List<ProductModel> products) async {
    await database.transaction(() async {
      await database.delete(database.localProductUnits).go();
      await database.delete(database.localProducts).go();

      final now = DateTime.now();
      await database.batch((batch) {
        for (final product in products) {
          batch.insert(
            database.localProducts,
            LocalProductsCompanion.insert(
              id: product.id,
              name: product.name,
              active: product.active,
              updatedAt: now,
            ),
          );
          for (final unit in product.units) {
            batch.insert(
              database.localProductUnits,
              LocalProductUnitsCompanion.insert(
                id: unit.id,
                productId: unit.productId,
                unit: unit.unit.databaseValue,
                unitPrice: unit.unitPrice,
                active: unit.active,
                updatedAt: now,
              ),
            );
          }
        }
      });
    });
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final products = await (database.select(
      database.localProducts,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    final units = await database.select(database.localProductUnits).get();

    final unitsByProduct = <String, List<LocalProductUnit>>{};
    for (final unit in units) {
      unitsByProduct.putIfAbsent(unit.productId, () => []).add(unit);
    }

    return [
      for (final product in products)
        ProductModel(
          id: product.id,
          name: product.name,
          active: product.active,
          units: [
            for (final unit in unitsByProduct[product.id] ?? const [])
              ProductUnitPriceModel(
                id: unit.id,
                productId: unit.productId,
                unit: ProductUnitOfMeasure.fromDatabase(unit.unit),
                unitPrice: unit.unitPrice,
                active: unit.active,
              ),
          ],
        ),
    ];
  }

  @override
  Future<void> updateProductName({
    required String id,
    required String name,
  }) async {
    await (database.update(
      database.localProducts,
    )..where((t) => t.id.equals(id))).write(
      LocalProductsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) async {
    await (database.update(
      database.localProductUnits,
    )..where((t) => t.id.equals(unitId))).write(
      LocalProductUnitsCompanion(
        unitPrice: Value(unitPrice),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> setActive(String id, bool active) async {
    await (database.update(
      database.localProducts,
    )..where((t) => t.id.equals(id))).write(
      LocalProductsCompanion(
        active: Value(active),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

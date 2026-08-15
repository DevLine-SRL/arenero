import 'package:drift/drift.dart';

import '../../../../core/models/app_database.dart';
import '../../../../core/models/sync_status.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_delivery_model.dart';
import '../models/sale_history_item_model.dart';
import '../models/sale_model.dart';

abstract class SalesLocalDataSource {
  Future<void> upsertSale(
    SaleModel sale, {
    SyncStatus syncStatus = SyncStatus.synced,
  });

  Future<void> upsertHistory(List<SaleHistoryItemModel> items);

  Future<SaleModel?> getSaleById(String saleId);

  Future<List<SaleHistoryItemModel>> getSaleHistory({
    DateTime? from,
    DateTime? to,
  });

  Future<List<SaleHistoryItemModel>> getPendingSalesHistory({
    DateTime? from,
    DateTime? to,
  });

  Future<List<SaleModel>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  });

  Future<void> markVoided(String saleId);

  Future<void> deleteById(String saleId);

  Future<void> reassignClientId({
    required String oldClientId,
    required String newClientId,
  });
}

class SalesLocalDataSourceImpl implements SalesLocalDataSource {
  final AppDatabase database;
  final String? Function() currentUserId;

  SalesLocalDataSourceImpl(this.database, {required this.currentUserId});

  @override
  Future<void> upsertSale(
    SaleModel sale, {
    SyncStatus syncStatus = SyncStatus.synced,
  }) async {
    final saleId = sale.id;
    if (saleId == null) return;

    final userId = currentUserId();
    if (userId == null) return;

    await database.transaction(() async {
      final now = DateTime.now();
      await database
          .into(database.localSales)
          .insert(
            LocalSalesCompanion.insert(
              id: saleId,
              userId: Value(userId),
              number: Value(sale.number),
              clientId: sale.client.id,
              sellerId: sale.sellerId,
              saleDate: sale.saleDate,
              deliveryMode: sale.deliveryMode.dbValue,
              paymentMethod: sale.paymentMethod.dbValue,
              status: sale.status.dbValue,
              total: sale.total,
              notes: Value(sale.notes),
              syncStatus: Value(syncStatus.dbValue),
              updatedAt: now,
            ),
            onConflict: DoUpdate(
              (_) => LocalSalesCompanion(
                number: Value(sale.number),
                clientId: Value(sale.client.id),
                sellerId: Value(sale.sellerId),
                saleDate: Value(sale.saleDate),
                deliveryMode: Value(sale.deliveryMode.dbValue),
                paymentMethod: Value(sale.paymentMethod.dbValue),
                status: Value(sale.status.dbValue),
                total: Value(sale.total),
                notes: Value(sale.notes),
                syncStatus: Value(syncStatus.dbValue),
                updatedAt: Value(now),
              ),
            ),
          );

      await (database.delete(
        database.localSaleDetails,
      )..where((t) => t.userId.equals(userId) & t.saleId.equals(saleId))).go();
      for (final detail in sale.details) {
        await database
            .into(database.localSaleDetails)
            .insert(
              LocalSaleDetailsCompanion.insert(
                id: detail.id ?? '$saleId-${detail.productUnitId}',
                userId: Value(userId),
                saleId: saleId,
                productUnitId: detail.productUnitId,
                unit: detail.unit.databaseValue,
                quantity: detail.quantity,
                unitPrice: detail.unitPrice,
                discount: detail.discount,
                productName: Value(detail.productName),
              ),
              onConflict: DoUpdate(
                (_) => LocalSaleDetailsCompanion(
                  saleId: Value(saleId),
                  productUnitId: Value(detail.productUnitId),
                  unit: Value(detail.unit.databaseValue),
                  quantity: Value(detail.quantity),
                  unitPrice: Value(detail.unitPrice),
                  discount: Value(detail.discount),
                  productName: Value(detail.productName),
                ),
              ),
            );
      }

      await (database.delete(
        database.localSaleDeliveries,
      )..where((t) => t.userId.equals(userId) & t.saleId.equals(saleId))).go();
      final delivery = sale.delivery;
      if (delivery != null) {
        await database
            .into(database.localSaleDeliveries)
            .insert(
              LocalSaleDeliveriesCompanion.insert(
                id: saleId,
                userId: Value(userId),
                saleId: saleId,
                deliveryAddress: Value(delivery.deliveryAddress),
                vehiclePlate: Value(delivery.vehiclePlate),
                deliveryDate: Value(delivery.deliveryDate),
              ),
            );
      }
    });
  }

  @override
  Future<void> upsertHistory(List<SaleHistoryItemModel> items) async {
    final userId = currentUserId();
    if (userId == null) return;

    final now = DateTime.now();
    await database.batch((batch) {
      for (final item in items) {
        batch.insert(
          database.localSaleHistory,
          LocalSaleHistoryCompanion.insert(
            id: item.id,
            userId: Value(userId),
            number: Value(item.number),
            clientName: item.clientName,
            clientCi: item.clientCi,
            saleDate: item.saleDate,
            total: item.total,
            paymentMethod: item.paymentMethod.dbValue,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => LocalSaleHistoryCompanion(
              number: Value(item.number),
              clientName: Value(item.clientName),
              clientCi: Value(item.clientCi),
              saleDate: Value(item.saleDate),
              total: Value(item.total),
              paymentMethod: Value(item.paymentMethod.dbValue),
              updatedAt: Value(now),
            ),
          ),
        );
      }
    });
  }

  @override
  Future<SaleModel?> getSaleById(String saleId) async {
    final userId = currentUserId();
    if (userId == null) return null;

    final sale =
        await (database.select(database.localSales)
              ..where((t) => t.userId.equals(userId) & t.id.equals(saleId)))
            .getSingleOrNull();
    if (sale == null) return null;

    return _saleFromCache(sale);
  }

  @override
  Future<List<SaleModel>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    final userId = currentUserId();
    if (userId == null) return [];

    final query = database.select(database.localSales);
    query.where((t) => t.userId.equals(userId));
    if (status != null) {
      query.where((t) => t.status.equals(status.dbValue));
    }
    if (from != null) {
      query.where((t) => t.saleDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.saleDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.saleDate)]);

    final rows = await query.get();
    return [for (final row in rows) await _saleFromCache(row)];
  }

  @override
  Future<List<SaleHistoryItemModel>> getSaleHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    final userId = currentUserId();
    if (userId == null) return [];

    final query = database.select(database.localSaleHistory);
    query.where((t) => t.userId.equals(userId));
    if (from != null) {
      query.where((t) => t.saleDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.saleDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.saleDate)]);

    final rows = await query.get();
    return [
      for (final row in rows)
        SaleHistoryItemModel(
          id: row.id,
          number: row.number,
          clientName: row.clientName,
          clientCi: row.clientCi,
          saleDate: row.saleDate,
          total: row.total,
          paymentMethod: SalePaymentMethod.fromDatabase(row.paymentMethod),
        ),
    ];
  }

  @override
  Future<List<SaleHistoryItemModel>> getPendingSalesHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    final userId = currentUserId();
    if (userId == null) return [];

    final query = database.select(database.localSales);
    query.where((t) => t.userId.equals(userId));
    query.where((t) => t.syncStatus.equals(SyncStatus.pending.dbValue));
    if (from != null) {
      query.where((t) => t.saleDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.saleDate.isSmallerOrEqualValue(to));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.saleDate)]);

    final rows = await query.get();
    final items = <SaleHistoryItemModel>[];
    for (final row in rows) {
      final client = await _cachedClient(row.clientId);
      items.add(
        SaleHistoryItemModel(
          id: row.id,
          number: row.number,
          clientName: client.name,
          clientCi: client.ci,
          saleDate: row.saleDate,
          total: row.total,
          paymentMethod: SalePaymentMethod.fromDatabase(row.paymentMethod),
        ),
      );
    }
    return items;
  }

  @override
  Future<void> markVoided(String saleId) async {
    final userId = currentUserId();
    if (userId == null) return;

    await (database.update(
      database.localSales,
    )..where((t) => t.userId.equals(userId) & t.id.equals(saleId))).write(
      LocalSalesCompanion(
        status: Value(SaleStatus.void_.dbValue),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteById(String saleId) async {
    final userId = currentUserId();
    if (userId == null) return;

    await database.transaction(() async {
      await (database.delete(
        database.localSaleDetails,
      )..where((t) => t.userId.equals(userId) & t.saleId.equals(saleId))).go();
      await (database.delete(
        database.localSaleDeliveries,
      )..where((t) => t.userId.equals(userId) & t.saleId.equals(saleId))).go();
      await (database.delete(
        database.localSaleHistory,
      )..where((t) => t.userId.equals(userId) & t.id.equals(saleId))).go();
      await (database.delete(
        database.localSales,
      )..where((t) => t.userId.equals(userId) & t.id.equals(saleId))).go();
    });
  }

  @override
  Future<void> reassignClientId({
    required String oldClientId,
    required String newClientId,
  }) async {
    final userId = currentUserId();
    if (userId == null) return;

    await (database.update(database.localSales)..where(
          (t) => t.userId.equals(userId) & t.clientId.equals(oldClientId),
        ))
        .write(LocalSalesCompanion(clientId: Value(newClientId)));
  }

  Future<SaleModel> _saleFromCache(LocalSale sale) async {
    final client = await _cachedClient(sale.clientId);
    final details = await _cachedDetails(sale.id);
    final delivery = await _cachedDelivery(sale.id);
    final sellerName = await _cachedSellerName(sale.sellerId);

    return SaleModel(
      id: sale.id,
      number: sale.number,
      client: client,
      sellerId: sale.sellerId,
      sellerName: sellerName,
      saleDate: sale.saleDate,
      deliveryMode: SaleDeliveryMode.fromDatabase(sale.deliveryMode),
      paymentMethod: SalePaymentMethod.fromDatabase(sale.paymentMethod),
      status: SaleStatus.fromDatabase(sale.status),
      total: sale.total,
      notes: sale.notes,
      details: details,
      delivery: delivery,
    );
  }

  Future<ClientModel> _cachedClient(String clientId) async {
    final userId = currentUserId();
    if (userId == null) {
      return ClientModel(id: clientId, name: 'Cliente', ci: '', active: true);
    }

    final row =
        await (database.select(database.localClients)
              ..where((t) => t.userId.equals(userId) & t.id.equals(clientId)))
            .getSingleOrNull();

    if (row == null) {
      return ClientModel(id: clientId, name: 'Cliente', ci: '', active: true);
    }
    return ClientModel(
      id: row.id,
      name: row.name,
      phone: row.phone,
      ci: row.ci,
      nit: row.nit,
      active: row.active,
    );
  }

  Future<List<SaleDetailModel>> _cachedDetails(String saleId) async {
    final userId = currentUserId();
    if (userId == null) return [];

    final rows = await (database.select(
      database.localSaleDetails,
    )..where((t) => t.userId.equals(userId) & t.saleId.equals(saleId))).get();

    return [
      for (final row in rows)
        SaleDetailModel(
          id: row.id,
          productUnitId: row.productUnitId,
          unit: ProductUnitOfMeasure.fromDatabase(row.unit),
          quantity: row.quantity,
          unitPrice: row.unitPrice,
          discount: row.discount,
          productName: row.productName,
        ),
    ];
  }

  Future<SaleDeliveryModel?> _cachedDelivery(String saleId) async {
    final userId = currentUserId();
    if (userId == null) return null;

    final row =
        await (database.select(database.localSaleDeliveries)
              ..where((t) => t.userId.equals(userId) & t.saleId.equals(saleId)))
            .getSingleOrNull();

    if (row == null) return null;
    return SaleDeliveryModel(
      deliveryAddress: row.deliveryAddress,
      vehiclePlate: row.vehiclePlate,
      deliveryDate: row.deliveryDate,
    );
  }

  Future<String?> _cachedSellerName(String sellerId) async {
    final row = await (database.select(
      database.localProfiles,
    )..where((t) => t.id.equals(sellerId))).getSingleOrNull();
    if (row == null) return null;

    final name = row.name;
    if (name != null && name.trim().isNotEmpty) return name;
    return row.email;
  }
}

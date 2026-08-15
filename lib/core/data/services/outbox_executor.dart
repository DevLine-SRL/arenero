import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../features/clients/data/datasources/clients_local_datasource.dart';
import '../../../features/clients/data/datasources/clients_remote_datasource.dart';
import '../../../features/sales/data/datasources/sales_local_datasource.dart';
import '../../../features/sales/data/datasources/sales_remote_datasource.dart';
import '../../../features/sales/data/models/sale_delivery_model.dart';
import '../../../features/sales/data/models/sale_detail_model.dart';
import '../../../features/sales/data/models/sale_history_item_model.dart';
import '../../../features/sales/data/models/sale_model.dart';
import '../../../features/sales/domain/entities/sale.dart';
import '../../errors/network_errors.dart';
import '../datasources/sync_local_datasource.dart';

abstract class OutboxExecutor {
  Future<bool> drain();
}

class OutboxExecutorImpl implements OutboxExecutor {
  final SyncLocalDataSource syncDataSource;
  final ClientsRemoteDataSource clientsRemoteDataSource;
  final SalesRemoteDataSource salesRemoteDataSource;
  final ClientsLocalDataSource clientsLocalDataSource;
  final SalesLocalDataSource salesLocalDataSource;
  final bool Function() isOnline;

  const OutboxExecutorImpl({
    required this.syncDataSource,
    required this.clientsRemoteDataSource,
    required this.salesRemoteDataSource,
    required this.clientsLocalDataSource,
    required this.salesLocalDataSource,
    required this.isOnline,
  });

  @override
  Future<bool> drain() async {
    if (!isOnline()) return false;

    var syncedAny = false;
    try {
      while (true) {
        final pending = await syncDataSource.getPendingOperations();
        if (pending.isEmpty) break;

        final operation = pending.first;
        try {
          await _process(operation);
          syncedAny = true;
        } on supabase.PostgrestException catch (e) {
          await syncDataSource.markFailed(operation.id, e.message);
        } catch (e) {
          if (isNetworkError(e)) return syncedAny;
          await syncDataSource.markFailed(operation.id, e.toString());
        }
      }
    } catch (_) {}
    return syncedAny;
  }

  Future<void> _process(PendingOperation operation) async {
    switch (operation.operation) {
      case OutboxOperationType.createClient:
        await _drainCreateClient(operation);
      case OutboxOperationType.registerSale:
        await _drainRegisterSale(operation);
    }
  }

  Future<void> _drainCreateClient(PendingOperation operation) async {
    final payload = operation.payload;
    final client = await clientsRemoteDataSource.createClient(
      name: payload['name'] as String,
      ci: payload['ci'] as String,
      phone: payload['phone'] as String?,
      nit: payload['nit'] as String?,
    );

    final tempId = payload['id'] as String;
    await clientsLocalDataSource.deleteById(tempId);
    await clientsLocalDataSource.upsertClients([client]);
    await salesLocalDataSource.reassignClientId(
      oldClientId: tempId,
      newClientId: client.id,
    );
    await _rewritePendingSalesForClient(
      oldClientId: tempId,
      newClientId: client.id,
    );
    await syncDataSource.markSynced(operation.id);
  }

  Future<void> _drainRegisterSale(PendingOperation operation) async {
    final payload = operation.payload;
    final sale = await salesRemoteDataSource.registerSale(
      clientId: payload['client_id'] as String,
      sellerId: payload['seller_id'] as String,
      deliveryMode: SaleDeliveryMode.fromDatabase(
        payload['delivery_mode'] as String,
      ),
      paymentMethod: SalePaymentMethod.fromDatabase(
        payload['payment_method'] as String,
      ),
      notes: payload['notes'] as String?,
      delivery: payload['delivery'] == null
          ? null
          : SaleDeliveryModel.fromJson(
              payload['delivery'] as Map<String, dynamic>,
            ),
      details: [
        for (final detail in payload['details'] as List)
          SaleDetailModel.fromJson(detail as Map<String, dynamic>),
      ],
    );

    await salesLocalDataSource.deleteById(payload['id'] as String);
    await salesLocalDataSource.upsertSale(sale);
    await salesLocalDataSource.upsertHistory([_historyItemFromSale(sale)]);
    await syncDataSource.markSynced(operation.id);
  }

  Future<void> _rewritePendingSalesForClient({
    required String oldClientId,
    required String newClientId,
  }) async {
    final pending = await syncDataSource.getPendingOperations();
    for (final operation in pending) {
      if (operation.operation != OutboxOperationType.registerSale) continue;
      if (operation.payload['client_id'] != oldClientId) continue;

      final updated = Map<String, dynamic>.from(operation.payload);
      updated['client_id'] = newClientId;
      await syncDataSource.updatePayload(operation.id, updated);
    }
  }

  SaleHistoryItemModel _historyItemFromSale(SaleModel sale) {
    return SaleHistoryItemModel(
      id: sale.id!,
      number: sale.number,
      clientName: sale.client.name,
      clientCi: sale.client.ci,
      saleDate: sale.saleDate,
      total: sale.total,
      paymentMethod: sale.paymentMethod,
    );
  }
}

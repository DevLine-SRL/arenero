import 'package:dartz/dartz.dart' as dartz;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';

import '../../../../core/data/datasources/sync_local_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_errors.dart';
import '../../../../core/models/sync_status.dart';
import '../../../clients/data/models/client_model.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_detail.dart';
import '../../domain/entities/sale_delivery.dart';
import '../../domain/entities/sale_history_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_local_datasource.dart';
import '../datasources/sales_remote_datasource.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_delivery_model.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  final SalesLocalDataSource localDataSource;
  final SyncLocalDataSource syncDataSource;
  final bool Function() isOnline;

  const SalesRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource, {
    required this.syncDataSource,
    required this.isOnline,
  });

  @override
  Future<dartz.Either<Failure, Sale>> registerSale({
    required String clientId,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  }) async {
    if (!isOnline()) {
      return _registerSaleOffline(
        clientId: clientId,
        sellerId: sellerId,
        deliveryMode: deliveryMode,
        paymentMethod: paymentMethod,
        notes: notes,
        delivery: delivery,
        details: details,
      );
    }
    try {
      final sale = await remoteDataSource.registerSale(
        clientId: clientId,
        sellerId: sellerId,
        deliveryMode: deliveryMode,
        paymentMethod: paymentMethod,
        notes: notes,
        delivery: delivery == null
            ? null
            : SaleDeliveryModel(
                deliveryAddress: delivery.deliveryAddress,
                vehiclePlate: delivery.vehiclePlate,
                deliveryDate: delivery.deliveryDate,
              ),
        details: [
          for (final detail in details)
            SaleDetailModel(
              productUnitId: detail.productUnitId,
              unit: detail.unit,
              quantity: detail.quantity,
              unitPrice: detail.unitPrice,
              discount: detail.discount,
            ),
        ],
      );
      await _syncLocal(() => localDataSource.upsertSale(sale));
      return dartz.Right(sale);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapRegisterError(e));
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(message: 'No se pudo registrar la venta.'),
      );
    }
  }

  Failure _mapRegisterError(supabase.PostgrestException e) {
    return switch (e.code) {
      '23505' => const ValidationFailure(
        message: 'No se pudo registrar la venta por un dato duplicado.',
        code: 'SALE_DUPLICATE',
      ),
      '23503' || '23502' => const ValidationFailure(
        message: 'Alguno de los datos de la venta no es válido.',
      ),
      '23514' || 'P0001' => const ValidationFailure(
        message:
            'No se pudo registrar la venta: revisa las cantidades y descuentos.',
      ),
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para registrar la venta.',
      ),
      _ => UnexpectedFailure(
        message: 'No se pudo registrar la venta.',
        code: e.code,
      ),
    };
  }

  /// Guarda la venta en la caché local como pendiente y encola la operación en
  /// el outbox para reproducirla en el servidor cuando vuelva la conexión.
  Future<dartz.Either<Failure, Sale>> _registerSaleOffline({
    required String clientId,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  }) async {
    final saleId = const Uuid().v4();
    final total = details.fold(0.0, (sum, detail) => sum + detail.subtotal);

    final detailModels = [
      for (final detail in details)
        SaleDetailModel(
          productUnitId: detail.productUnitId,
          unit: detail.unit,
          quantity: detail.quantity,
          unitPrice: detail.unitPrice,
          discount: detail.discount,
        ),
    ];
    final deliveryModel = delivery == null
        ? null
        : SaleDeliveryModel(
            deliveryAddress: delivery.deliveryAddress,
            vehiclePlate: delivery.vehiclePlate,
            deliveryDate: delivery.deliveryDate,
          );

    final sale = SaleModel(
      id: saleId,
      client: ClientModel(id: clientId, name: 'Cliente', ci: '', active: true),
      sellerId: sellerId,
      saleDate: DateTime.now(),
      deliveryMode: deliveryMode,
      paymentMethod: paymentMethod,
      total: total,
      notes: notes,
      details: detailModels,
      delivery: deliveryModel,
    );

    try {
      await localDataSource.upsertSale(sale, syncStatus: SyncStatus.pending);
      await syncDataSource.enqueue(
        operation: OutboxOperationType.registerSale,
        payload: {
          'id': sale.id,
          'client_id': clientId,
          'seller_id': sellerId,
          'sale_date': sale.saleDate.toIso8601String(),
          'delivery_mode': deliveryMode.dbValue,
          'payment_method': paymentMethod.dbValue,
          'notes': notes,
          'total': total,
          'delivery': deliveryModel?.toJson(),
          'details': [for (final detail in detailModels) detail.toJson()],
        },
      );
      return dartz.Right(sale);
    } catch (_) {
      return const dartz.Left(
        CacheFailure(message: 'No se pudo guardar la venta sin conexión.'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, List<Sale>>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    if (!isOnline()) {
      return _cachedSales(status: status, from: from, to: to);
    }
    try {
      final sales = await remoteDataSource.getSales(
        status: status,
        from: from,
        to: to,
      );
      await _syncSales(sales);
      return dartz.Right(sales);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(
        UnexpectedFailure(
          message: 'No se pudieron obtener las ventas.',
          code: e.code,
        ),
      );
    } catch (e) {
      if (isNetworkError(e)) {
        return _cachedSales(status: status, from: from, to: to);
      }
      return const dartz.Left(
        UnexpectedFailure(message: 'No se pudieron obtener las ventas.'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, List<SaleHistoryItem>>> getSalesHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    if (!isOnline()) {
      return getCachedSalesHistory(from: from, to: to);
    }
    try {
      final items = await remoteDataSource.getSalesHistory(from: from, to: to);
      await _syncLocal(() => localDataSource.upsertHistory(items));
      return dartz.Right(items);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapHistoryError(e));
    } catch (e) {
      if (isNetworkError(e)) {
        return getCachedSalesHistory(from: from, to: to);
      }
      return const dartz.Left(
        UnexpectedFailure(
          message: 'No se pudo obtener el historial de ventas.',
        ),
      );
    }
  }

  Failure _mapHistoryError(supabase.PostgrestException e) {
    return switch (e.code) {
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para ver el historial de ventas.',
      ),
      _ => UnexpectedFailure(
        message: 'No se pudo obtener el historial de ventas.',
        code: e.code,
      ),
    };
  }

  @override
  Future<dartz.Either<Failure, Sale>> getSaleById(String saleId) async {
    if (!isOnline()) {
      return getCachedSaleById(saleId);
    }
    try {
      final sale = await remoteDataSource.getSaleById(saleId);
      await _syncLocal(() => localDataSource.upsertSale(sale));
      return dartz.Right(sale);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapDetailError(e));
    } catch (e) {
      if (isNetworkError(e)) {
        return getCachedSaleById(saleId);
      }
      return const dartz.Left(
        UnexpectedFailure(
          message: 'No se pudo obtener el detalle de la venta.',
        ),
      );
    }
  }

  Failure _mapDetailError(supabase.PostgrestException e) {
    return switch (e.code) {
      'PGRST116' => const NotFoundFailure(message: 'La venta no existe.'),
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para ver esta venta.',
      ),
      _ => UnexpectedFailure(
        message: 'No se pudo obtener el detalle de la venta.',
        code: e.code,
      ),
    };
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> voidSale(String saleId) async {
    if (!isOnline()) {
      return const dartz.Left(NetworkFailure());
    }
    try {
      await remoteDataSource.voidSale(saleId);
      await _syncLocal(() => localDataSource.markVoided(saleId));
      return const dartz.Right(dartz.unit);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapVoidError(e));
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(message: 'No se pudo anular la venta.'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, List<SaleHistoryItem>>> getCachedSalesHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final cached = await localDataSource.getSaleHistory(from: from, to: to);
      if (cached.isEmpty) {
        return const dartz.Left(NetworkFailure());
      }
      return dartz.Right(cached);
    } catch (_) {
      return const dartz.Left(
        CacheFailure(message: 'No se pudo leer el historial local.'),
      );
    }
  }

  @override
  Future<dartz.Either<Failure, Sale>> getCachedSaleById(String saleId) async {
    try {
      final cached = await localDataSource.getSaleById(saleId);
      if (cached == null) {
        return const dartz.Left(NetworkFailure());
      }
      return dartz.Right(cached);
    } catch (_) {
      return const dartz.Left(
        CacheFailure(message: 'No se pudo leer la venta local.'),
      );
    }
  }

  Future<dartz.Either<Failure, List<Sale>>> _cachedSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final cached = await localDataSource.getSales(
        status: status,
        from: from,
        to: to,
      );
      if (cached.isEmpty) {
        return const dartz.Left(NetworkFailure());
      }
      return dartz.Right(cached);
    } catch (_) {
      return const dartz.Left(
        CacheFailure(message: 'No se pudo leer las ventas locales.'),
      );
    }
  }

  Future<void> _syncSales(List<SaleModel> sales) async {
    for (final sale in sales) {
      await _syncLocal(() => localDataSource.upsertSale(sale));
    }
  }

  Future<void> _syncLocal(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {}
  }

  Failure _mapVoidError(supabase.PostgrestException e) {
    return switch (e.code) {
      'P0002' => const NotFoundFailure(message: 'La venta no existe.'),
      'P0001' => const ValidationFailure(message: 'La venta ya está anulada.'),
      '42501' => const UnauthorizedFailure(
        message: 'No tienes permisos para anular la venta.',
      ),
      _ => UnexpectedFailure(
        message: 'No se pudo anular la venta.',
        code: e.code,
      ),
    };
  }
}

import 'package:dartz/dartz.dart' as dartz;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_detail.dart';
import '../../domain/entities/sale_delivery.dart';
import '../../domain/entities/sale_history_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';
import '../models/sale_detail_model.dart';
import '../models/sale_delivery_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  const SalesRepositoryImpl(this.remoteDataSource);

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

  @override
  Future<dartz.Either<Failure, List<Sale>>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final sales = await remoteDataSource.getSales(
        status: status,
        from: from,
        to: to,
      );
      return dartz.Right(sales);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(
        UnexpectedFailure(
          message: 'No se pudieron obtener las ventas.',
          code: e.code,
        ),
      );
    } catch (_) {
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
    try {
      final items = await remoteDataSource.getSalesHistory(from: from, to: to);
      return dartz.Right(items);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapHistoryError(e));
    } catch (_) {
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
  Future<dartz.Either<Failure, dartz.Unit>> voidSale(String saleId) async {
    try {
      await remoteDataSource.voidSale(saleId);
      return const dartz.Right(dartz.unit);
    } on supabase.PostgrestException catch (e) {
      return dartz.Left(_mapVoidError(e));
    } catch (_) {
      return const dartz.Left(
        UnexpectedFailure(message: 'No se pudo anular la venta.'),
      );
    }
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

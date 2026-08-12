import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/sales/domain/entities/sale.dart';
import 'package:arenero/features/sales/domain/entities/sale_delivery.dart';
import 'package:arenero/features/sales/domain/entities/sale_detail.dart';
import 'package:arenero/features/sales/domain/entities/sale_history_item.dart';
import 'package:arenero/features/sales/domain/repositories/sales_repository.dart';
import 'package:dartz/dartz.dart';

import '../builders/sale_builder.dart';

/// Repositorio de mentira, escrito a mano. Los métodos que una prueba no
/// configura lanzan `UnimplementedError`.
class FakeSalesRepository implements SalesRepository {
  Either<Failure, Sale>? saleDetailResult;
  String? lastRequestedSaleId;

  @override
  Future<Either<Failure, Sale>> getSaleById(String saleId) async {
    lastRequestedSaleId = saleId;
    return saleDetailResult ?? Right(buildSale());
  }

  @override
  Future<Either<Failure, Sale>> registerSale({
    required String clientId,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Sale>>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<SaleHistoryItem>>> getSalesHistory({
    DateTime? from,
    DateTime? to,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> voidSale(String saleId) async {
    throw UnimplementedError();
  }
}

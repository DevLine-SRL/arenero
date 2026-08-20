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
  Either<Failure, Sale>? registerResult;
  Either<Failure, Unit>? updatePaymentResult;
  String? lastRequestedSaleId;
  String? lastRegisteredClientId;
  String? lastRegisteredSellerId;
  double? lastRegisteredDiscountAmount;
  double? lastRegisteredFreightAmount;
  List<SaleDetail>? lastRegisteredDetails;
  String? lastUpdatedPaymentSaleId;
  SalePaymentStatus? lastUpdatedPaymentStatus;
  double? lastUpdatedAmountPaid;
  double? lastUpdatedPendingAmount;

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
    required double discountAmount,
    required double freightAmount,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  }) async {
    lastRegisteredClientId = clientId;
    lastRegisteredSellerId = sellerId;
    lastRegisteredDiscountAmount = discountAmount;
    lastRegisteredFreightAmount = freightAmount;
    lastRegisteredDetails = details;
    return registerResult ?? Right(buildSale(total: 100, pendingAmount: 100));
  }

  @override
  Future<Either<Failure, Unit>> updateSalePayment({
    required String saleId,
    required SalePaymentStatus paymentStatus,
    required double amountPaid,
    required double pendingAmount,
  }) async {
    lastUpdatedPaymentSaleId = saleId;
    lastUpdatedPaymentStatus = paymentStatus;
    lastUpdatedAmountPaid = amountPaid;
    lastUpdatedPendingAmount = pendingAmount;
    return updatePaymentResult ?? const Right(unit);
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

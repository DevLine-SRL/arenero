import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../clients/domain/entities/client.dart';
import '../entities/sale.dart';
import '../entities/sale_detail.dart';
import '../entities/sale_delivery.dart';
import '../entities/sale_history_item.dart';

abstract class SalesRepository {
  Future<Either<Failure, Sale>> registerSale({
    required Client client,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  });

  Future<Either<Failure, List<Sale>>> getSales({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  });

  Future<Either<Failure, List<SaleHistoryItem>>> getSalesHistory({
    DateTime? from,
    DateTime? to,
  });

  Future<Either<Failure, List<SaleHistoryItem>>> getCachedSalesHistory({
    DateTime? from,
    DateTime? to,
  });

  Future<Either<Failure, Sale>> getSaleById(String saleId);

  Future<Either<Failure, Sale>> getCachedSaleById(String saleId);

  Future<Either<Failure, Unit>> voidSale(String saleId);
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../clients/domain/entities/client.dart';
import '../entities/sale.dart';
import '../entities/sale_detail.dart';
import '../entities/sale_delivery.dart';
import '../repositories/sales_repository.dart';

class RegisterSaleUseCase {
  final SalesRepository repository;

  const RegisterSaleUseCase(this.repository);

  Future<Either<Failure, Sale>> call({
    required Client client,
    required String sellerId,
    required SaleDeliveryMode deliveryMode,
    required SalePaymentMethod paymentMethod,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  }) {
    return repository.registerSale(
      client: client,
      sellerId: sellerId,
      deliveryMode: deliveryMode,
      paymentMethod: paymentMethod,
      notes: notes,
      delivery: delivery,
      details: details,
    );
  }
}

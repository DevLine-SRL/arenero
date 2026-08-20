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
    required double discountAmount,
    required double freightAmount,
    String? notes,
    SaleDelivery? delivery,
    required List<SaleDetail> details,
  }) {
    return repository.registerSale(
      clientId: client.id,
      sellerId: sellerId,
      deliveryMode: deliveryMode,
      paymentMethod: paymentMethod,
      discountAmount: discountAmount,
      freightAmount: freightAmount,
      notes: notes,
      delivery: delivery,
      details: details,
    );
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class UpdateSalePaymentUseCase {
  final SalesRepository repository;

  const UpdateSalePaymentUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String saleId,
    required SalePaymentStatus paymentStatus,
    required double amountPaid,
    required double pendingAmount,
  }) {
    return repository.updateSalePayment(
      saleId: saleId,
      paymentStatus: paymentStatus,
      amountPaid: amountPaid,
      pendingAmount: pendingAmount,
    );
  }
}

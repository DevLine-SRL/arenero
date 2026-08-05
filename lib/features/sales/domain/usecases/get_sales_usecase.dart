import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetSalesUseCase {
  final SalesRepository repository;

  const GetSalesUseCase(this.repository);

  Future<Either<Failure, List<Sale>>> call({
    SaleStatus? status,
    DateTime? from,
    DateTime? to,
  }) {
    return repository.getSales(status: status, from: from, to: to);
  }
}

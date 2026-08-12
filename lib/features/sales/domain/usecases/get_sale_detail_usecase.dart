import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetSaleDetailUseCase {
  final SalesRepository repository;

  const GetSaleDetailUseCase(this.repository);

  Future<Either<Failure, Sale>> call(String saleId) {
    return repository.getSaleById(saleId);
  }
}

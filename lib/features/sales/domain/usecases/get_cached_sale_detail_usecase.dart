import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetCachedSaleDetailUseCase {
  final SalesRepository repository;

  const GetCachedSaleDetailUseCase(this.repository);

  Future<Either<Failure, Sale>> call(String saleId) {
    return repository.getCachedSaleById(saleId);
  }
}

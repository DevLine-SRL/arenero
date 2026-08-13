import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale_history_item.dart';
import '../repositories/sales_repository.dart';

class GetCachedSalesHistoryUseCase {
  final SalesRepository repository;

  const GetCachedSalesHistoryUseCase(this.repository);

  Future<Either<Failure, List<SaleHistoryItem>>> call({
    DateTime? from,
    DateTime? to,
  }) {
    return repository.getCachedSalesHistory(from: from, to: to);
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale_history_item.dart';
import '../repositories/sales_repository.dart';

class GetSalesHistoryUseCase {
  final SalesRepository repository;

  const GetSalesHistoryUseCase(this.repository);

  Future<Either<Failure, List<SaleHistoryItem>>> call({
    DateTime? from,
    DateTime? to,
  }) {
    return repository.getSalesHistory(from: from, to: to);
  }
}

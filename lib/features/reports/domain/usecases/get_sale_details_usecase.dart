import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sale_details_page.dart';
import '../repositories/reports_repository.dart';

class GetSaleDetailsUseCase {
  final ReportsRepository repository;

  const GetSaleDetailsUseCase(this.repository);

  Future<Either<Failure, SaleDetailsPage>> call({
    required DateTime start,
    required DateTime end,
    String? clientId,
    String? sellerId,
    String search = '',
    String orderColumn = 'sale_date',
    bool ascending = false,
    required int page,
    int pageSize = 8,
  }) {
    return repository.getSaleDetails(
      start: start,
      end: end,
      clientId: clientId,
      sellerId: sellerId,
      search: search,
      orderColumn: orderColumn,
      ascending: ascending,
      page: page,
      pageSize: pageSize,
    );
  }
}

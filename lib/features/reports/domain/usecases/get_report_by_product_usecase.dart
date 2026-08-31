import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_report_row.dart';
import '../repositories/reports_repository.dart';

class GetReportByProductUseCase {
  final ReportsRepository repository;

  const GetReportByProductUseCase(this.repository);

  Future<Either<Failure, List<ProductReportRow>>> call({
    required DateTime start,
    required DateTime end,
  }) {
    return repository.getReportByProduct(start: start, end: end);
  }
}

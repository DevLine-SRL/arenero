import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/seller_report_row.dart';
import '../repositories/reports_repository.dart';

class GetReportBySellerUseCase {
  final ReportsRepository repository;

  const GetReportBySellerUseCase(this.repository);

  Future<Either<Failure, List<SellerReportRow>>> call({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) {
    return repository.getReportBySeller(start: start, end: end, limit: limit);
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_report_row.dart';
import '../repositories/reports_repository.dart';

class GetReportByClientUseCase {
  final ReportsRepository repository;

  const GetReportByClientUseCase(this.repository);

  Future<Either<Failure, List<ClientReportRow>>> call({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) {
    return repository.getReportByClient(start: start, end: end, limit: limit);
  }
}

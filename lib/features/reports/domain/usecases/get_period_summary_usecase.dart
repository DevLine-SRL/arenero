import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/period_summary.dart';
import '../repositories/reports_repository.dart';

class GetPeriodSummaryUseCase {
  final ReportsRepository repository;

  const GetPeriodSummaryUseCase(this.repository);

  Future<Either<Failure, PeriodSummary>> call({
    required DateTime start,
    required DateTime end,
  }) {
    return repository.getPeriodSummary(start: start, end: end);
  }
}

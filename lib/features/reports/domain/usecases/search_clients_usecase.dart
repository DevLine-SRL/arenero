import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/report_suggestion.dart';
import '../repositories/reports_repository.dart';

class SearchClientsUseCase {
  final ReportsRepository repository;

  const SearchClientsUseCase(this.repository);

  Future<Either<Failure, List<ReportSuggestion>>> call(String query) {
    return repository.searchClients(query);
  }
}

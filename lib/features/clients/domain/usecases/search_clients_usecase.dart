import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class SearchClientsUseCase {
  final ClientsRepository repository;

  const SearchClientsUseCase(this.repository);

  Future<Either<Failure, List<Client>>> call({
    String query = '',
    bool includeInactive = false,
  }) {
    return repository.searchClients(
      query: query,
      includeInactive: includeInactive,
    );
  }
}

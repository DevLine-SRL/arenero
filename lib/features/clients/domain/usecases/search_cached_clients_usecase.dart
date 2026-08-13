import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class SearchCachedClientsUseCase {
  final ClientsRepository repository;

  const SearchCachedClientsUseCase(this.repository);

  Future<Either<Failure, List<Client>>> call({
    required String query,
    bool includeInactive = false,
  }) {
    return repository.searchCachedClients(
      query: query,
      includeInactive: includeInactive,
    );
  }
}

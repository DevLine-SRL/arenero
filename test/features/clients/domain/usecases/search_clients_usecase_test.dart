import 'package:arenero/features/clients/domain/usecases/search_clients_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/client_builder.dart';
import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late SearchClientsUseCase useCase;

  setUp(() {
    repository = FakeClientsRepository();
    useCase = SearchClientsUseCase(repository);
  });

  test('searches active clients only by default', () async {
    await useCase();

    expect(repository.lastSearchQuery, '');
    expect(repository.lastIncludeInactive, isFalse);
  });

  test('forwards the query and the inactive flag', () async {
    await useCase(query: 'juan', includeInactive: true);

    expect(repository.lastSearchQuery, 'juan');
    expect(repository.lastIncludeInactive, isTrue);
  });

  test('returns the clients the repository found', () async {
    repository.searchResult = Right([buildClient(name: 'Ana')]);

    final result = await useCase(query: 'ana');

    expect(result.getOrElse(() => []).single.name, 'Ana');
  });
}

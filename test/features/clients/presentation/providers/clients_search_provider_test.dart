import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/presentation/providers/clients_search_provider.dart';
import 'package:arenero/features/clients/presentation/providers/clients_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/client_builder.dart';
import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeClientsRepository();
    container = ProviderContainer(
      overrides: [clientsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('ClientsSearch', () {
    test('builds with all clients including inactive ones', () async {
      repository.searchResult = Right([
        buildClient(id: '1', active: true),
        buildClient(id: '2', active: false),
      ]);

      final clients = await container.read(clientsSearchProvider.future);

      expect(clients, hasLength(2));
      expect(repository.lastIncludeInactive, isTrue);
    });

    test('setActive delegates each id to the usecase and reloads', () async {
      repository.searchResult = const Right([]);
      await container.read(clientsSearchProvider.future);

      await container.read(clientsSearchProvider.notifier).setActive({
        '1',
        '2',
      }, false);

      expect(repository.setActiveCallCount, 2);
      // Tras invalidar, la consulta se vuelve a lanzar, no solo se confía en
      // el estado optimista.
      expect(repository.lastSearchQuery, '');
    });

    test('setActive does nothing with an empty selection', () async {
      await container.read(clientsSearchProvider.future);

      await container.read(clientsSearchProvider.notifier).setActive({}, true);

      expect(repository.setActiveCallCount, 0);
    });

    test('updateClient edits the client and reloads on success', () async {
      repository.searchResult = const Right([]);
      await container.read(clientsSearchProvider.future);

      final failure = await container
          .read(clientsSearchProvider.notifier)
          .updateClient(
            buildClient(id: '1'),
            name: 'Nuevo nombre',
            ci: '1234567',
          );

      expect(failure, isNull);
      expect(repository.lastUpdatedId, '1');
      expect(repository.lastUpdatedName, 'Nuevo nombre');
    });

    test(
      'updateClient surfaces the failure without closing the flow',
      () async {
        repository.searchResult = const Right([]);
        repository.updateResult = const Left(
          UnexpectedFailure(message: 'No se pudo actualizar el cliente.'),
        );
        await container.read(clientsSearchProvider.future);

        final failure = await container
            .read(clientsSearchProvider.notifier)
            .updateClient(
              buildClient(id: '1'),
              name: 'Nuevo nombre',
              ci: '1234567',
            );

        expect(failure, isA<UnexpectedFailure>());
      },
    );
  });
}

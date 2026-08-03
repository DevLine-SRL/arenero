import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/domain/usecases/create_client_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late CreateClientUseCase useCase;

  setUp(() {
    repository = FakeClientsRepository();
    useCase = CreateClientUseCase(repository);
  });

  test('builds a Ci and forwards the client data to the repository', () async {
    final result = await useCase(
      name: 'Juan Pérez',
      rawCi: '1234567',
      phone: '70011223',
    );

    expect(result.isRight(), isTrue);
    expect(repository.lastCreatedName, 'Juan Pérez');
    expect(repository.lastCreatedCi, '1234567');
    expect(repository.lastCreatedPhone, '70011223');
  });

  test('rejects an invalid ci without reaching the repository', () async {
    final result = await useCase(name: 'Juan Pérez', rawCi: '12A');

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('expected a failure'),
    );
    expect(repository.createCallCount, 0);
  });
}

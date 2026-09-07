import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/domain/usecases/update_client_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late UpdateClientUseCase useCase;

  setUp(() {
    repository = FakeClientsRepository();
    useCase = UpdateClientUseCase(repository);
  });

  test('builds a Ci and forwards the client data to the repository', () async {
    final result = await useCase(
      id: 'client-1',
      name: 'Juan Pérez',
      rawCi: '1234567',
      phone: '70011223',
      nit: '1234567890',
    );

    expect(result.isRight(), isTrue);
    expect(repository.lastUpdatedId, 'client-1');
    expect(repository.lastUpdatedName, 'Juan Pérez');
    expect(repository.lastUpdatedCi, '1234567');
    expect(repository.lastUpdatedPhone, '70011223');
    expect(repository.lastUpdatedNit, '1234567890');
  });

  test('rejects an invalid ci without reaching the repository', () async {
    final result = await useCase(
      id: 'client-1',
      name: 'Juan Pérez',
      rawCi: '12A',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('expected a failure'),
    );
    expect(repository.updateCallCount, 0);
  });

  test('trims the ci before forwarding it', () async {
    await useCase(id: 'client-1', name: 'Juan Pérez', rawCi: ' 1234567 ');

    expect(repository.lastUpdatedCi, '1234567');
  });

  test('surfaces a repository failure', () async {
    repository.updateResult = const Left(
      ValidationFailure(message: 'Ya existe un cliente con esa cédula.'),
    );

    final result = await useCase(
      id: 'client-1',
      name: 'Juan Pérez',
      rawCi: '1234567',
    );

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((failure) => failure.message, (_) => ''),
      contains('cédula'),
    );
  });
}

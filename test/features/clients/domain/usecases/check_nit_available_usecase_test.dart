import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/domain/usecases/check_nit_available_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late CheckNitAvailableUseCase useCase;

  setUp(() {
    repository = FakeClientsRepository();
    useCase = CheckNitAvailableUseCase(repository);
  });

  test('reports available when no client holds the nit', () async {
    repository.existsByNitResult = const Right(false);

    final result = await useCase('12345');

    expect(result.getOrElse(() => false), isTrue);
    expect(repository.lastCheckedNit, '12345');
  });

  test('reports unavailable when a client already holds the nit', () async {
    repository.existsByNitResult = const Right(true);

    final result = await useCase('12345');

    expect(result.getOrElse(() => true), isFalse);
  });

  test('treats an empty nit as available because it is optional', () async {
    final result = await useCase('   ');

    expect(result.getOrElse(() => false), isTrue);
    expect(repository.existsByNitCallCount, 0);
  });

  test('rejects a malformed nit without reaching the repository', () async {
    final result = await useCase('12A45');

    expect(result.isLeft(), isTrue);
    expect(repository.existsByNitCallCount, 0);
  });

  test('propagates a repository failure', () async {
    repository.existsByNitResult = const Left(UnexpectedFailure());

    final result = await useCase('12345');

    expect(result.isLeft(), isTrue);
  });
}

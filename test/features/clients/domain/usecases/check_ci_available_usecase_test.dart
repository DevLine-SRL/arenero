import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/domain/usecases/check_ci_available_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late CheckCiAvailableUseCase useCase;

  setUp(() {
    repository = FakeClientsRepository();
    useCase = CheckCiAvailableUseCase(repository);
  });

  test('reports available when no client holds the ci', () async {
    repository.existsResult = const Right(false);

    final result = await useCase('1234567');

    expect(result.getOrElse(() => false), isTrue);
    expect(repository.lastCheckedCi?.value, '1234567');
  });

  test('reports unavailable when a client already holds the ci', () async {
    repository.existsResult = const Right(true);

    final result = await useCase('1234567');

    expect(result.getOrElse(() => true), isFalse);
  });

  test('rejects an invalid ci without reaching the repository', () async {
    final result = await useCase('12A');

    expect(result.isLeft(), isTrue);
    expect(repository.existsCallCount, 0);
  });

  test('propagates a repository failure', () async {
    repository.existsResult = const Left(UnexpectedFailure());

    final result = await useCase('1234567');

    expect(result.isLeft(), isTrue);
  });
}

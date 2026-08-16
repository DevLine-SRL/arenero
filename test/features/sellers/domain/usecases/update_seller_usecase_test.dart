import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/sellers/domain/entities/seller.dart';
import 'package:arenero/features/sellers/domain/repositories/sellers_repository.dart';
import 'package:arenero/features/sellers/domain/usecases/update_seller_usecase.dart';
import 'package:arenero/shared/value_objects/value_objects.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSellerUseCase', () {
    test('returns a validation failure when the name is empty', () async {
      final repository = _FakeSellersRepository();
      final useCase = UpdateSellerUseCase(repository);

      final result = await useCase(
        id: 'seller-1',
        name: ' ',
        rawEmail: 'seller@example.com',
        existingSellers: const [Seller(id: 'seller-1', email: 'seller@example.com', name: 'Ana', active: true)],
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected validation failure'),
      );
      expect(repository.updateCallCount, 0);
    });

    test('updates the seller when the data is valid', () async {
      final repository = _FakeSellersRepository();
      final useCase = UpdateSellerUseCase(repository);

      final result = await useCase(
        id: 'seller-1',
        name: 'Ana López',
        rawEmail: 'ana.nueva@example.com',
        existingSellers: const [Seller(id: 'seller-1', email: 'seller@example.com', name: 'Ana', active: true)],
      );

      expect(result.isRight(), isTrue);
      expect(repository.updateCallCount, 1);
      expect(repository.lastUpdatedId, 'seller-1');
      expect(repository.lastUpdatedName, 'Ana López');
      expect(repository.lastUpdatedEmail, 'ana.nueva@example.com');
    });
  });
}

class _FakeSellersRepository implements SellersRepository {
  int updateCallCount = 0;
  String? lastUpdatedId;
  String? lastUpdatedName;
  String? lastUpdatedEmail;

  @override
  Future<Either<Failure, List<Seller>>> getSellers() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> setActive(String id, bool active) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> createSeller({
    required FullName name,
    required Email email,
    required Password password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> updateSeller({
    required String id,
    required FullName name,
    required Email email,
  }) async {
    updateCallCount++;
    lastUpdatedId = id;
    lastUpdatedName = name.value;
    lastUpdatedEmail = email.value;
    return const Right(unit);
  }
}

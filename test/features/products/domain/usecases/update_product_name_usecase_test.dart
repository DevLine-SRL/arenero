import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/products/domain/repositories/products_repository.dart';
import 'package:arenero/features/products/domain/usecases/update_product_name_usecase.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateProductNameUseCase', () {
    test('does not update when the name belongs to another product', () async {
      final repository = _ProductsRepositoryFake();
      final useCase = UpdateProductNameUseCase(repository);

      final result = await useCase(
        id: 'product-1',
        name: '  gravilla ',
        existingProducts: const [
          Product(id: 'product-1', name: 'Arena fina', active: true),
          Product(id: 'product-2', name: 'Gravilla', active: true),
        ],
      );

      expect(result.isLeft(), isTrue);
      expect(repository.updateCalls, 0);
    });

    test('updates its own name after normalizing it', () async {
      final repository = _ProductsRepositoryFake();
      final useCase = UpdateProductNameUseCase(repository);

      final result = await useCase(
        id: 'product-1',
        name: '  arena   lavada ',
        existingProducts: const [
          Product(id: 'product-1', name: 'Arena fina', active: true),
        ],
      );

      expect(result.isRight(), isTrue);
      expect(repository.updateCalls, 1);
      expect(repository.lastId, 'product-1');
      expect(repository.lastName, 'Arena Lavada');
    });
  });
}

class _ProductsRepositoryFake implements ProductsRepository {
  int updateCalls = 0;
  String? lastId;
  String? lastName;

  @override
  Future<dartz.Either<Failure, dartz.Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, List<Product>>> getProducts() {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> setActive(
    String id,
    bool active,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateProductName({
    required String id,
    required String name,
  }) async {
    updateCalls++;
    lastId = id;
    lastName = name;
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) {
    throw UnimplementedError();
  }
}

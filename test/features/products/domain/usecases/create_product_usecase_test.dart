import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/products/domain/repositories/products_repository.dart';
import 'package:arenero/features/products/domain/usecases/create_product_usecase.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateProductUseCase', () {
    test(
      'bloquea productos duplicados antes de llamar al repositorio',
      () async {
        final repository = _ProductsRepositoryFake();
        final useCase = CreateProductUseCase(repository);

        final result = await useCase(
          name: 'arena fina',
          unit: ProductUnitOfMeasure.m3,
          unitPrice: 50,
          existingProducts: const [
            Product(id: 'p1', name: 'Arena Fina', active: true),
          ],
        );

        expect(result.isLeft(), isTrue);
        expect(repository.createCalls, 0);
        result.fold(
          (failure) => expect(failure.code, 'PRODUCT_DUPLICATE'),
          (_) => fail('El caso duplicado debe fallar.'),
        );
      },
    );

    test('rechaza precios menores o iguales a cero', () async {
      final repository = _ProductsRepositoryFake();
      final useCase = CreateProductUseCase(repository);

      final result = await useCase(
        name: 'Arena fina',
        unit: ProductUnitOfMeasure.m3,
        unitPrice: 0,
        existingProducts: const [],
      );

      expect(result.isLeft(), isTrue);
      expect(repository.createCalls, 0);
      result.fold(
        (failure) => expect(failure.code, 'INVALID_UNIT_PRICE'),
        (_) => fail('El precio invalido debe fallar.'),
      );
    });

    test(
      'registra productos validos con nombre normalizado para guardar',
      () async {
        final repository = _ProductsRepositoryFake();
        final useCase = CreateProductUseCase(repository);

        final result = await useCase(
          name: '  arena   fina  ',
          unit: ProductUnitOfMeasure.m3,
          unitPrice: 50,
          existingProducts: const [],
        );

        expect(result.isRight(), isTrue);
        expect(repository.createCalls, 1);
        expect(repository.lastName, 'Arena Fina');
      },
    );
  });
}

class _ProductsRepositoryFake implements ProductsRepository {
  int createCalls = 0;
  String? lastName;

  @override
  Future<dartz.Either<Failure, dartz.Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) async {
    createCalls++;
    lastName = name;
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, List<Product>>> getProducts() async {
    return const dartz.Right([]);
  }

  @override
  Future<dartz.Either<Failure, List<Product>>> getCachedProducts() {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> setActive(
    String id,
    bool active,
  ) async {
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateProductName({
    required String id,
    required String name,
  }) async {
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) async => const dartz.Right(dartz.unit);
}

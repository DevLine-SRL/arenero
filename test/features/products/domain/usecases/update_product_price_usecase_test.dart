import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/products/domain/repositories/products_repository.dart';
import 'package:arenero/features/products/domain/usecases/update_product_price_usecase.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = Product(id: 'product-1', name: 'Arena fina', active: true);
  const unit = ProductUnitPrice(
    id: 'unit-1',
    productId: 'product-1',
    unit: ProductUnitOfMeasure.m3,
    unitPrice: 50,
    active: true,
  );

  group('UpdateProductPriceUseCase', () {
    test('rejects a price that is not greater than zero', () async {
      final repository = _ProductsRepositoryFake();
      final result = await UpdateProductPriceUseCase(repository)(
        product: product,
        unit: unit,
        unitPrice: 0,
      );

      expect(result.isLeft(), isTrue);
      expect(repository.updateCalls, 0);
    });

    test('updates the active unit price', () async {
      final repository = _ProductsRepositoryFake();
      final result = await UpdateProductPriceUseCase(repository)(
        product: product,
        unit: unit,
        unitPrice: 75.5,
      );

      expect(result.isRight(), isTrue);
      expect(repository.updateCalls, 1);
      expect(repository.lastUnitId, 'unit-1');
      expect(repository.lastPrice, 75.5);
    });
  });
}

class _ProductsRepositoryFake implements ProductsRepository {
  int updateCalls = 0;
  String? lastUnitId;
  double? lastPrice;

  @override
  Future<dartz.Either<Failure, dartz.Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) => throw UnimplementedError();

  @override
  Future<dartz.Either<Failure, List<Product>>> getProducts() =>
      throw UnimplementedError();

  @override
  Future<dartz.Either<Failure, List<Product>>> getCachedProducts() =>
      throw UnimplementedError();

  @override
  Future<dartz.Either<Failure, dartz.Unit>> setActive(String id, bool active) =>
      throw UnimplementedError();

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateProductName({
    required String id,
    required String name,
  }) => throw UnimplementedError();

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) async {
    updateCalls++;
    lastUnitId = unitId;
    lastPrice = unitPrice;
    return const dartz.Right(dartz.unit);
  }
}

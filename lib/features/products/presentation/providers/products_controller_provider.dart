import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/product_duplicate_guard.dart';
import 'products_providers.dart';

final productsControllerProvider =
    AsyncNotifierProvider<ProductsController, List<Product>>(
      ProductsController.new,
    );

class ProductsController extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final useCase = ref.watch(getProductsUseCaseProvider);
    final result = await useCase();

    return result.fold((failure) => throw failure, (products) => products);
  }

  Future<Failure?> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) async {
    final currentProducts = state.value ?? const <Product>[];
    final useCase = ref.read(createProductUseCaseProvider);

    final result = await useCase(
      name: name,
      unit: unit,
      unitPrice: unitPrice,
      existingProducts: currentProducts,
    );

    return result.fold(
      (failure) async {
        state = await AsyncValue.guard(_fetchProducts);
        return failure;
      },
      (_) async {
        state = const AsyncLoading();
        state = await AsyncValue.guard(_fetchProducts);
        return null;
      },
    );
  }

  Future<Failure?> setActive(String id, bool active) async {
    final previous = state.value;

    state = state.whenData(
      (products) => [
        for (final product in products)
          if (product.id == id) product.copyWith(active: active) else product,
      ],
    );

    final result = await ref.read(setProductActiveUseCaseProvider)(
      id: id,
      active: active,
    );

    return result.fold((failure) {
      if (previous != null) state = AsyncData(previous);
      return failure;
    }, (_) => null);
  }

  Future<Failure?> updateProductName(Product product, String name) async {
    final previous = state.value;
    final currentProducts = previous ?? const <Product>[];
    final result = await ref.read(updateProductNameUseCaseProvider)(
      id: product.id,
      name: name,
      existingProducts: currentProducts,
    );

    return result.fold((failure) => failure, (_) {
      final normalizedName = normalizeProductName(name);
      final displayName = normalizedName
          .split(' ')
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
      state = state.whenData(
        (products) => [
          for (final current in products)
            if (current.id == product.id)
              current.copyWith(name: displayName)
            else
              current,
        ],
      );
      return null;
    });
  }

  Future<Failure?> updateProductPrice(
    Product product,
    ProductUnitPrice unit,
    double unitPrice,
  ) async {
    final result = await ref.read(updateProductPriceUseCaseProvider)(
      product: product,
      unit: unit,
      unitPrice: unitPrice,
    );
    return result.fold((failure) => failure, (_) {
      state = state.whenData(
        (products) => [
          for (final current in products)
            if (current.id == product.id)
              current.copyWith(
                units: [
                  for (final currentUnit in current.units)
                    if (currentUnit.id == unit.id)
                      currentUnit.copyWith(unitPrice: unitPrice)
                    else
                      currentUnit,
                ],
              )
            else
              current,
        ],
      );
      return null;
    });
  }
}

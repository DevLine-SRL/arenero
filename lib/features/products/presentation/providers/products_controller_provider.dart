import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
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
}

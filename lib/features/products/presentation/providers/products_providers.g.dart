// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productsRemoteDataSource)
final productsRemoteDataSourceProvider = ProductsRemoteDataSourceProvider._();

final class ProductsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProductsRemoteDataSource,
          ProductsRemoteDataSource,
          ProductsRemoteDataSource
        >
    with $Provider<ProductsRemoteDataSource> {
  ProductsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProductsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductsRemoteDataSource create(Ref ref) {
    return productsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductsRemoteDataSource>(value),
    );
  }
}

String _$productsRemoteDataSourceHash() =>
    r'9e399aa686dcddce317429190305021b5f046e3c';

@ProviderFor(productsLocalDataSource)
final productsLocalDataSourceProvider = ProductsLocalDataSourceProvider._();

final class ProductsLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ProductsLocalDataSource,
          ProductsLocalDataSource,
          ProductsLocalDataSource
        >
    with $Provider<ProductsLocalDataSource> {
  ProductsLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProductsLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductsLocalDataSource create(Ref ref) {
    return productsLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductsLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductsLocalDataSource>(value),
    );
  }
}

String _$productsLocalDataSourceHash() =>
    r'1f24de1a9be59e58ac7668de3bfc4bb42b4f67cd';

@ProviderFor(productsRepository)
final productsRepositoryProvider = ProductsRepositoryProvider._();

final class ProductsRepositoryProvider
    extends
        $FunctionalProvider<
          ProductsRepository,
          ProductsRepository,
          ProductsRepository
        >
    with $Provider<ProductsRepository> {
  ProductsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductsRepository create(Ref ref) {
    return productsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductsRepository>(value),
    );
  }
}

String _$productsRepositoryHash() =>
    r'89b6db64bb085e9a3d9ab75503ec4c1990fb9b7b';

@ProviderFor(getProductsUseCase)
final getProductsUseCaseProvider = GetProductsUseCaseProvider._();

final class GetProductsUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductsUseCase,
          GetProductsUseCase,
          GetProductsUseCase
        >
    with $Provider<GetProductsUseCase> {
  GetProductsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductsUseCase create(Ref ref) {
    return getProductsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductsUseCase>(value),
    );
  }
}

String _$getProductsUseCaseHash() =>
    r'8d795d8eb5232498a8d081bd2aa99d492e6b8043';

@ProviderFor(getCachedProductsUseCase)
final getCachedProductsUseCaseProvider = GetCachedProductsUseCaseProvider._();

final class GetCachedProductsUseCaseProvider
    extends
        $FunctionalProvider<
          GetCachedProductsUseCase,
          GetCachedProductsUseCase,
          GetCachedProductsUseCase
        >
    with $Provider<GetCachedProductsUseCase> {
  GetCachedProductsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCachedProductsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCachedProductsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCachedProductsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCachedProductsUseCase create(Ref ref) {
    return getCachedProductsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCachedProductsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCachedProductsUseCase>(value),
    );
  }
}

String _$getCachedProductsUseCaseHash() =>
    r'bff8b6bbe3cf14bb6cd3aed1e37de7aa0b3270ad';

@ProviderFor(createProductUseCase)
final createProductUseCaseProvider = CreateProductUseCaseProvider._();

final class CreateProductUseCaseProvider
    extends
        $FunctionalProvider<
          CreateProductUseCase,
          CreateProductUseCase,
          CreateProductUseCase
        >
    with $Provider<CreateProductUseCase> {
  CreateProductUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createProductUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createProductUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateProductUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateProductUseCase create(Ref ref) {
    return createProductUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateProductUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateProductUseCase>(value),
    );
  }
}

String _$createProductUseCaseHash() =>
    r'b2215509cfdf772423618085a2314a65915ce019';

@ProviderFor(setProductActiveUseCase)
final setProductActiveUseCaseProvider = SetProductActiveUseCaseProvider._();

final class SetProductActiveUseCaseProvider
    extends
        $FunctionalProvider<
          SetProductActiveUseCase,
          SetProductActiveUseCase,
          SetProductActiveUseCase
        >
    with $Provider<SetProductActiveUseCase> {
  SetProductActiveUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setProductActiveUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setProductActiveUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetProductActiveUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetProductActiveUseCase create(Ref ref) {
    return setProductActiveUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetProductActiveUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetProductActiveUseCase>(value),
    );
  }
}

String _$setProductActiveUseCaseHash() =>
    r'45a89ae9b1cdb69a3970e308d4aa853685e44317';

@ProviderFor(updateProductNameUseCase)
final updateProductNameUseCaseProvider = UpdateProductNameUseCaseProvider._();

final class UpdateProductNameUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateProductNameUseCase,
          UpdateProductNameUseCase,
          UpdateProductNameUseCase
        >
    with $Provider<UpdateProductNameUseCase> {
  UpdateProductNameUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProductNameUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProductNameUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProductNameUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateProductNameUseCase create(Ref ref) {
    return updateProductNameUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProductNameUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProductNameUseCase>(value),
    );
  }
}

String _$updateProductNameUseCaseHash() =>
    r'926c3b927f27b2cb250323ebbbb38cf6e88930eb';

@ProviderFor(updateProductPriceUseCase)
final updateProductPriceUseCaseProvider = UpdateProductPriceUseCaseProvider._();

final class UpdateProductPriceUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateProductPriceUseCase,
          UpdateProductPriceUseCase,
          UpdateProductPriceUseCase
        >
    with $Provider<UpdateProductPriceUseCase> {
  UpdateProductPriceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProductPriceUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProductPriceUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProductPriceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateProductPriceUseCase create(Ref ref) {
    return updateProductPriceUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProductPriceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProductPriceUseCase>(value),
    );
  }
}

String _$updateProductPriceUseCaseHash() =>
    r'64be8fac08dc242e3ab223a100fec6128b67a4fe';

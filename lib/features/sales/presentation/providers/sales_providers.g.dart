// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(salesRemoteDataSource)
final salesRemoteDataSourceProvider = SalesRemoteDataSourceProvider._();

final class SalesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SalesRemoteDataSource,
          SalesRemoteDataSource,
          SalesRemoteDataSource
        >
    with $Provider<SalesRemoteDataSource> {
  SalesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SalesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SalesRemoteDataSource create(Ref ref) {
    return salesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalesRemoteDataSource>(value),
    );
  }
}

String _$salesRemoteDataSourceHash() =>
    r'2de43d70db4f8015378eb8bb4c42cb0d2504f140';

@ProviderFor(salesLocalDataSource)
final salesLocalDataSourceProvider = SalesLocalDataSourceProvider._();

final class SalesLocalDataSourceProvider
    extends
        $FunctionalProvider<
          SalesLocalDataSource,
          SalesLocalDataSource,
          SalesLocalDataSource
        >
    with $Provider<SalesLocalDataSource> {
  SalesLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<SalesLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SalesLocalDataSource create(Ref ref) {
    return salesLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalesLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalesLocalDataSource>(value),
    );
  }
}

String _$salesLocalDataSourceHash() =>
    r'ed80e5486d36ebad98d30e25ee26bcda097e9729';

@ProviderFor(salesRepository)
final salesRepositoryProvider = SalesRepositoryProvider._();

final class SalesRepositoryProvider
    extends
        $FunctionalProvider<SalesRepository, SalesRepository, SalesRepository>
    with $Provider<SalesRepository> {
  SalesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SalesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SalesRepository create(Ref ref) {
    return salesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalesRepository>(value),
    );
  }
}

String _$salesRepositoryHash() => r'f2e02e406754068b9c12cbecdca9cbe04ab970fe';

@ProviderFor(registerSaleUseCase)
final registerSaleUseCaseProvider = RegisterSaleUseCaseProvider._();

final class RegisterSaleUseCaseProvider
    extends
        $FunctionalProvider<
          RegisterSaleUseCase,
          RegisterSaleUseCase,
          RegisterSaleUseCase
        >
    with $Provider<RegisterSaleUseCase> {
  RegisterSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerSaleUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterSaleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegisterSaleUseCase create(Ref ref) {
    return registerSaleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterSaleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterSaleUseCase>(value),
    );
  }
}

String _$registerSaleUseCaseHash() =>
    r'6f90403f2333488385ddaa37a653cdaaa5a18916';

@ProviderFor(getSalesUseCase)
final getSalesUseCaseProvider = GetSalesUseCaseProvider._();

final class GetSalesUseCaseProvider
    extends
        $FunctionalProvider<GetSalesUseCase, GetSalesUseCase, GetSalesUseCase>
    with $Provider<GetSalesUseCase> {
  GetSalesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSalesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSalesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSalesUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetSalesUseCase create(Ref ref) {
    return getSalesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSalesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSalesUseCase>(value),
    );
  }
}

String _$getSalesUseCaseHash() => r'70ecb349c1eb93bdeb41af97cd2c91de1b77176c';

@ProviderFor(getSalesHistoryUseCase)
final getSalesHistoryUseCaseProvider = GetSalesHistoryUseCaseProvider._();

final class GetSalesHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetSalesHistoryUseCase,
          GetSalesHistoryUseCase,
          GetSalesHistoryUseCase
        >
    with $Provider<GetSalesHistoryUseCase> {
  GetSalesHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSalesHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSalesHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSalesHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSalesHistoryUseCase create(Ref ref) {
    return getSalesHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSalesHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSalesHistoryUseCase>(value),
    );
  }
}

String _$getSalesHistoryUseCaseHash() =>
    r'bf4cbf673d21e3d893d35cd872e9bb763575df2f';

@ProviderFor(getCachedSalesHistoryUseCase)
final getCachedSalesHistoryUseCaseProvider =
    GetCachedSalesHistoryUseCaseProvider._();

final class GetCachedSalesHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetCachedSalesHistoryUseCase,
          GetCachedSalesHistoryUseCase,
          GetCachedSalesHistoryUseCase
        >
    with $Provider<GetCachedSalesHistoryUseCase> {
  GetCachedSalesHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCachedSalesHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCachedSalesHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCachedSalesHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCachedSalesHistoryUseCase create(Ref ref) {
    return getCachedSalesHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCachedSalesHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCachedSalesHistoryUseCase>(value),
    );
  }
}

String _$getCachedSalesHistoryUseCaseHash() =>
    r'43b377c6634e995864c758bc90378194333381d5';

@ProviderFor(getSaleDetailUseCase)
final getSaleDetailUseCaseProvider = GetSaleDetailUseCaseProvider._();

final class GetSaleDetailUseCaseProvider
    extends
        $FunctionalProvider<
          GetSaleDetailUseCase,
          GetSaleDetailUseCase,
          GetSaleDetailUseCase
        >
    with $Provider<GetSaleDetailUseCase> {
  GetSaleDetailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSaleDetailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSaleDetailUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSaleDetailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSaleDetailUseCase create(Ref ref) {
    return getSaleDetailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSaleDetailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSaleDetailUseCase>(value),
    );
  }
}

String _$getSaleDetailUseCaseHash() =>
    r'abab35da03e53ae8ddebba395c9232e482074664';

@ProviderFor(getCachedSaleDetailUseCase)
final getCachedSaleDetailUseCaseProvider =
    GetCachedSaleDetailUseCaseProvider._();

final class GetCachedSaleDetailUseCaseProvider
    extends
        $FunctionalProvider<
          GetCachedSaleDetailUseCase,
          GetCachedSaleDetailUseCase,
          GetCachedSaleDetailUseCase
        >
    with $Provider<GetCachedSaleDetailUseCase> {
  GetCachedSaleDetailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCachedSaleDetailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCachedSaleDetailUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCachedSaleDetailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCachedSaleDetailUseCase create(Ref ref) {
    return getCachedSaleDetailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCachedSaleDetailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCachedSaleDetailUseCase>(value),
    );
  }
}

String _$getCachedSaleDetailUseCaseHash() =>
    r'c0972c94e375ee0e17792e8255f13a0897074e19';

@ProviderFor(voidSaleUseCase)
final voidSaleUseCaseProvider = VoidSaleUseCaseProvider._();

final class VoidSaleUseCaseProvider
    extends
        $FunctionalProvider<VoidSaleUseCase, VoidSaleUseCase, VoidSaleUseCase>
    with $Provider<VoidSaleUseCase> {
  VoidSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voidSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voidSaleUseCaseHash();

  @$internal
  @override
  $ProviderElement<VoidSaleUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VoidSaleUseCase create(Ref ref) {
    return voidSaleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoidSaleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoidSaleUseCase>(value),
    );
  }
}

String _$voidSaleUseCaseHash() => r'166cc2b58f7eb7b760ce33faa2e2957852f409ab';

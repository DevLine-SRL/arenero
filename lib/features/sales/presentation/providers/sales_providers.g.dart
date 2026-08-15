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

String _$salesRepositoryHash() => r'2d7d1d2ae3e912be7c2b19a0a4adf5d772ed9a0e';

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

@ProviderFor(updateSalePaymentUseCase)
final updateSalePaymentUseCaseProvider = UpdateSalePaymentUseCaseProvider._();

final class UpdateSalePaymentUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateSalePaymentUseCase,
          UpdateSalePaymentUseCase,
          UpdateSalePaymentUseCase
        >
    with $Provider<UpdateSalePaymentUseCase> {
  UpdateSalePaymentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateSalePaymentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateSalePaymentUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateSalePaymentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateSalePaymentUseCase create(Ref ref) {
    return updateSalePaymentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSalePaymentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSalePaymentUseCase>(value),
    );
  }
}

String _$updateSalePaymentUseCaseHash() =>
    r'1a39a08ed384bc9142959e5986011d0c4d1f54ca';

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

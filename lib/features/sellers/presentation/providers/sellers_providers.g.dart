// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sellers_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sellersRemoteDataSource)
final sellersRemoteDataSourceProvider = SellersRemoteDataSourceProvider._();

final class SellersRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SellersRemoteDataSource,
          SellersRemoteDataSource,
          SellersRemoteDataSource
        >
    with $Provider<SellersRemoteDataSource> {
  SellersRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellersRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellersRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SellersRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SellersRemoteDataSource create(Ref ref) {
    return sellersRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SellersRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SellersRemoteDataSource>(value),
    );
  }
}

String _$sellersRemoteDataSourceHash() =>
    r'7ab26632319709e5dbfcac95a8908a63f30e5ca1';

@ProviderFor(sellersRepository)
final sellersRepositoryProvider = SellersRepositoryProvider._();

final class SellersRepositoryProvider
    extends
        $FunctionalProvider<
          SellersRepository,
          SellersRepository,
          SellersRepository
        >
    with $Provider<SellersRepository> {
  SellersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellersRepositoryHash();

  @$internal
  @override
  $ProviderElement<SellersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SellersRepository create(Ref ref) {
    return sellersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SellersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SellersRepository>(value),
    );
  }
}

String _$sellersRepositoryHash() => r'2e00a90ebd1c0c201ce148916902b7e494b2817e';

@ProviderFor(getSellersUseCase)
final getSellersUseCaseProvider = GetSellersUseCaseProvider._();

final class GetSellersUseCaseProvider
    extends
        $FunctionalProvider<
          GetSellersUseCase,
          GetSellersUseCase,
          GetSellersUseCase
        >
    with $Provider<GetSellersUseCase> {
  GetSellersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSellersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSellersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSellersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSellersUseCase create(Ref ref) {
    return getSellersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSellersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSellersUseCase>(value),
    );
  }
}

String _$getSellersUseCaseHash() => r'f41e46761b9c24b90e209de20718cd22721e83a4';

@ProviderFor(setSellersActiveUseCase)
final setSellersActiveUseCaseProvider = SetSellersActiveUseCaseProvider._();

final class SetSellersActiveUseCaseProvider
    extends
        $FunctionalProvider<
          SetSellersActiveUseCase,
          SetSellersActiveUseCase,
          SetSellersActiveUseCase
        >
    with $Provider<SetSellersActiveUseCase> {
  SetSellersActiveUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setSellersActiveUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setSellersActiveUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetSellersActiveUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetSellersActiveUseCase create(Ref ref) {
    return setSellersActiveUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetSellersActiveUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetSellersActiveUseCase>(value),
    );
  }
}

String _$setSellersActiveUseCaseHash() =>
    r'bb6e396826f342932f6c82ece3a4c2bf9f64085e';

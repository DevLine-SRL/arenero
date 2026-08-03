// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientsRemoteDataSource)
final clientsRemoteDataSourceProvider = ClientsRemoteDataSourceProvider._();

final class ClientsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ClientsRemoteDataSource,
          ClientsRemoteDataSource,
          ClientsRemoteDataSource
        >
    with $Provider<ClientsRemoteDataSource> {
  ClientsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ClientsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientsRemoteDataSource create(Ref ref) {
    return clientsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsRemoteDataSource>(value),
    );
  }
}

String _$clientsRemoteDataSourceHash() =>
    r'26a70f69cb3b8237c4084f00be1ccb4c834e7505';

@ProviderFor(clientsRepository)
final clientsRepositoryProvider = ClientsRepositoryProvider._();

final class ClientsRepositoryProvider
    extends
        $FunctionalProvider<
          ClientsRepository,
          ClientsRepository,
          ClientsRepository
        >
    with $Provider<ClientsRepository> {
  ClientsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClientsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientsRepository create(Ref ref) {
    return clientsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsRepository>(value),
    );
  }
}

String _$clientsRepositoryHash() => r'53daee75d08d263a40817ba8249c46f6a4731776';

@ProviderFor(searchClientsUseCase)
final searchClientsUseCaseProvider = SearchClientsUseCaseProvider._();

final class SearchClientsUseCaseProvider
    extends
        $FunctionalProvider<
          SearchClientsUseCase,
          SearchClientsUseCase,
          SearchClientsUseCase
        >
    with $Provider<SearchClientsUseCase> {
  SearchClientsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchClientsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchClientsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchClientsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchClientsUseCase create(Ref ref) {
    return searchClientsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchClientsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchClientsUseCase>(value),
    );
  }
}

String _$searchClientsUseCaseHash() =>
    r'6a65b2b25296eef5185b7fa1430dcff66be78c49';

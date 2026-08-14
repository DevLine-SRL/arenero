// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_local_datasource_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncLocalDataSource)
final syncLocalDataSourceProvider = SyncLocalDataSourceProvider._();

final class SyncLocalDataSourceProvider
    extends
        $FunctionalProvider<
          SyncLocalDataSource,
          SyncLocalDataSource,
          SyncLocalDataSource
        >
    with $Provider<SyncLocalDataSource> {
  SyncLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<SyncLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncLocalDataSource create(Ref ref) {
    return syncLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncLocalDataSource>(value),
    );
  }
}

String _$syncLocalDataSourceHash() =>
    r'45fdbeb828e3acb69cb18878b76f9555c32eabdc';

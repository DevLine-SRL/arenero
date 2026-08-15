// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InitialSync)
final initialSyncProvider = InitialSyncProvider._();

final class InitialSyncProvider extends $NotifierProvider<InitialSync, void> {
  InitialSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialSyncHash();

  @$internal
  @override
  InitialSync create() => InitialSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$initialSyncHash() => r'd0d360fe43a4b09fe1140783215b086284dffed7';

abstract class _$InitialSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

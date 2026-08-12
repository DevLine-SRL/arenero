// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_seen_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LastSeenSync)
final lastSeenSyncProvider = LastSeenSyncProvider._();

final class LastSeenSyncProvider extends $NotifierProvider<LastSeenSync, void> {
  LastSeenSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastSeenSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastSeenSyncHash();

  @$internal
  @override
  LastSeenSync create() => LastSeenSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$lastSeenSyncHash() => r'1378180a52a65fbe35dc81ff00522ca18be9c6c6';

abstract class _$LastSeenSync extends $Notifier<void> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OutboxSync)
final outboxSyncProvider = OutboxSyncProvider._();

final class OutboxSyncProvider extends $NotifierProvider<OutboxSync, void> {
  OutboxSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxSyncHash();

  @$internal
  @override
  OutboxSync create() => OutboxSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$outboxSyncHash() => r'4caaa40a8036897d253ee9e24090d9016d53326b';

abstract class _$OutboxSync extends $Notifier<void> {
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

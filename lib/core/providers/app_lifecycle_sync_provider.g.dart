// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lifecycle_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Refresca la data y el outbox cuando la app vuelve al primer plano.

@ProviderFor(AppLifecycleSync)
final appLifecycleSyncProvider = AppLifecycleSyncProvider._();

/// Refresca la data y el outbox cuando la app vuelve al primer plano.
final class AppLifecycleSyncProvider
    extends $NotifierProvider<AppLifecycleSync, void> {
  /// Refresca la data y el outbox cuando la app vuelve al primer plano.
  AppLifecycleSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLifecycleSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLifecycleSyncHash();

  @$internal
  @override
  AppLifecycleSync create() => AppLifecycleSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$appLifecycleSyncHash() => r'f872cf81ab1b6616eb288e9538c076b85bbd7096';

/// Refresca la data y el outbox cuando la app vuelve al primer plano.

abstract class _$AppLifecycleSync extends $Notifier<void> {
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

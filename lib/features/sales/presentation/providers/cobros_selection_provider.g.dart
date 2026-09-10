// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cobros_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CobrosSelection)
final cobrosSelectionProvider = CobrosSelectionProvider._();

final class CobrosSelectionProvider
    extends $NotifierProvider<CobrosSelection, Set<String>> {
  CobrosSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cobrosSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cobrosSelectionHash();

  @$internal
  @override
  CobrosSelection create() => CobrosSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$cobrosSelectionHash() => r'99f1722d12f3163fe30c198dbe409534a6cdc1b1';

abstract class _$CobrosSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

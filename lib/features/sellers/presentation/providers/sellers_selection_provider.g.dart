// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sellers_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SellersSelection)
final sellersSelectionProvider = SellersSelectionProvider._();

final class SellersSelectionProvider
    extends $NotifierProvider<SellersSelection, Set<String>> {
  SellersSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellersSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellersSelectionHash();

  @$internal
  @override
  SellersSelection create() => SellersSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$sellersSelectionHash() => r'204451c092707e2f9dac67021ed98692052699de';

abstract class _$SellersSelection extends $Notifier<Set<String>> {
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

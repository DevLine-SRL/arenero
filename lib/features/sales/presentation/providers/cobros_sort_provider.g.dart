// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cobros_sort_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CobrosSort)
final cobrosSortProvider = CobrosSortProvider._();

final class CobrosSortProvider
    extends $NotifierProvider<CobrosSort, CobrosSortOption?> {
  CobrosSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cobrosSortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cobrosSortHash();

  @$internal
  @override
  CobrosSort create() => CobrosSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CobrosSortOption? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CobrosSortOption?>(value),
    );
  }
}

String _$cobrosSortHash() => r'3502473318285c6b0d5b1c602998750e5190c91a';

abstract class _$CobrosSort extends $Notifier<CobrosSortOption?> {
  CobrosSortOption? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CobrosSortOption?, CobrosSortOption?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CobrosSortOption?, CobrosSortOption?>,
              CobrosSortOption?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

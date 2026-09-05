// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_sort_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SalesHistorySort)
final salesHistorySortProvider = SalesHistorySortProvider._();

final class SalesHistorySortProvider
    extends $NotifierProvider<SalesHistorySort, SalesHistorySortOption?> {
  SalesHistorySortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesHistorySortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistorySortHash();

  @$internal
  @override
  SalesHistorySort create() => SalesHistorySort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalesHistorySortOption? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalesHistorySortOption?>(value),
    );
  }
}

String _$salesHistorySortHash() => r'13386a1ff313e7b8aa6f12ebb037511ab70073d4';

abstract class _$SalesHistorySort extends $Notifier<SalesHistorySortOption?> {
  SalesHistorySortOption? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SalesHistorySortOption?, SalesHistorySortOption?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SalesHistorySortOption?, SalesHistorySortOption?>,
              SalesHistorySortOption?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

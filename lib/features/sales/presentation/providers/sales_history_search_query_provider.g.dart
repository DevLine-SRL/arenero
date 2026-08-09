// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_search_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SalesHistorySearchQuery)
final salesHistorySearchQueryProvider = SalesHistorySearchQueryProvider._();

final class SalesHistorySearchQueryProvider
    extends $NotifierProvider<SalesHistorySearchQuery, String> {
  SalesHistorySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesHistorySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistorySearchQueryHash();

  @$internal
  @override
  SalesHistorySearchQuery create() => SalesHistorySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$salesHistorySearchQueryHash() =>
    r'1201a9ce3804e3eb6bc010d4f2a9385f5454edf2';

abstract class _$SalesHistorySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_date_range_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SalesHistoryDateRange)
final salesHistoryDateRangeProvider = SalesHistoryDateRangeProvider._();

final class SalesHistoryDateRangeProvider
    extends $NotifierProvider<SalesHistoryDateRange, DateRangeFilter> {
  SalesHistoryDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesHistoryDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistoryDateRangeHash();

  @$internal
  @override
  SalesHistoryDateRange create() => SalesHistoryDateRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRangeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRangeFilter>(value),
    );
  }
}

String _$salesHistoryDateRangeHash() =>
    r'ea4e481288191770d727e4adbcd0c744ae3eb0ca';

abstract class _$SalesHistoryDateRange extends $Notifier<DateRangeFilter> {
  DateRangeFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateRangeFilter, DateRangeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateRangeFilter, DateRangeFilter>,
              DateRangeFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

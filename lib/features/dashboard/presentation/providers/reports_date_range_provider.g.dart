// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_date_range_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReportsDateRange)
final reportsDateRangeProvider = ReportsDateRangeProvider._();

final class ReportsDateRangeProvider
    extends $NotifierProvider<ReportsDateRange, ReportsDateRangeFilter> {
  ReportsDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsDateRangeHash();

  @$internal
  @override
  ReportsDateRange create() => ReportsDateRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsDateRangeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsDateRangeFilter>(value),
    );
  }
}

String _$reportsDateRangeHash() => r'e59ae2cc17e8f5959ab49bd2db6d7a0ce7e098bf';

abstract class _$ReportsDateRange extends $Notifier<ReportsDateRangeFilter> {
  ReportsDateRangeFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ReportsDateRangeFilter, ReportsDateRangeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportsDateRangeFilter, ReportsDateRangeFilter>,
              ReportsDateRangeFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

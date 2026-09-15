// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportsSummary)
final reportsSummaryProvider = ReportsSummaryProvider._();

final class ReportsSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportsSummaryData>,
          ReportsSummaryData,
          FutureOr<ReportsSummaryData>
        >
    with
        $FutureModifier<ReportsSummaryData>,
        $FutureProvider<ReportsSummaryData> {
  ReportsSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<ReportsSummaryData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportsSummaryData> create(Ref ref) {
    return reportsSummary(ref);
  }
}

String _$reportsSummaryHash() => r'd2bde61a48067b8837e8711610ed792e67afbd8a';

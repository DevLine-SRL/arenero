// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_seller_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectedSellerReport)
final selectedSellerReportProvider = SelectedSellerReportFamily._();

final class SelectedSellerReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SellerReportRow?>,
          SellerReportRow?,
          FutureOr<SellerReportRow?>
        >
    with $FutureModifier<SellerReportRow?>, $FutureProvider<SellerReportRow?> {
  SelectedSellerReportProvider._({
    required SelectedSellerReportFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'selectedSellerReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedSellerReportHash();

  @override
  String toString() {
    return r'selectedSellerReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SellerReportRow?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SellerReportRow?> create(Ref ref) {
    final argument = this.argument as String?;
    return selectedSellerReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedSellerReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedSellerReportHash() =>
    r'd0548e1fdbb20bd0255cb42986d17792d8361720';

final class SelectedSellerReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SellerReportRow?>, String?> {
  SelectedSellerReportFamily._()
    : super(
        retry: null,
        name: r'selectedSellerReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SelectedSellerReportProvider call(String? sellerId) =>
      SelectedSellerReportProvider._(argument: sellerId, from: this);

  @override
  String toString() => r'selectedSellerReportProvider';
}

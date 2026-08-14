// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportsProducts)
final reportsProductsProvider = ReportsProductsProvider._();

final class ReportsProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductReportRow>>,
          List<ProductReportRow>,
          FutureOr<List<ProductReportRow>>
        >
    with
        $FutureModifier<List<ProductReportRow>>,
        $FutureProvider<List<ProductReportRow>> {
  ReportsProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProductReportRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductReportRow>> create(Ref ref) {
    return reportsProducts(ref);
  }
}

String _$reportsProductsHash() => r'81c8420801d5f1fd54c17c5ee238459b618be7dd';

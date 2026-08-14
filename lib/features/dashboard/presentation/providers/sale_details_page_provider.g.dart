// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_details_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleDetailsPage)
final saleDetailsPageProvider = SaleDetailsPageFamily._();

final class SaleDetailsPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaleDetailsPage>,
          SaleDetailsPage,
          FutureOr<SaleDetailsPage>
        >
    with $FutureModifier<SaleDetailsPage>, $FutureProvider<SaleDetailsPage> {
  SaleDetailsPageProvider._({
    required SaleDetailsPageFamily super.from,
    required SaleDetailsRequest super.argument,
  }) : super(
         retry: null,
         name: r'saleDetailsPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleDetailsPageHash();

  @override
  String toString() {
    return r'saleDetailsPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SaleDetailsPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaleDetailsPage> create(Ref ref) {
    final argument = this.argument as SaleDetailsRequest;
    return saleDetailsPage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDetailsPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDetailsPageHash() => r'0287fab8b6865be9efc4f3f0e4157239abbb2d91';

final class SaleDetailsPageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SaleDetailsPage>,
          SaleDetailsRequest
        > {
  SaleDetailsPageFamily._()
    : super(
        retry: null,
        name: r'saleDetailsPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleDetailsPageProvider call(SaleDetailsRequest request) =>
      SaleDetailsPageProvider._(argument: request, from: this);

  @override
  String toString() => r'saleDetailsPageProvider';
}

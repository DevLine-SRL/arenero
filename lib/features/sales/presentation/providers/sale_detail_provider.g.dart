// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleDetail)
final saleDetailProvider = SaleDetailFamily._();

final class SaleDetailProvider
    extends $FunctionalProvider<AsyncValue<Sale>, Sale, FutureOr<Sale>>
    with $FutureModifier<Sale>, $FutureProvider<Sale> {
  SaleDetailProvider._({
    required SaleDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleDetailHash();

  @override
  String toString() {
    return r'saleDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Sale> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Sale> create(Ref ref) {
    final argument = this.argument as String;
    return saleDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDetailHash() => r'fcc947fb32e33a267b365950e0a72407dbfeac00';

final class SaleDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Sale>, String> {
  SaleDetailFamily._()
    : super(
        retry: null,
        name: r'saleDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleDetailProvider call(String saleId) =>
      SaleDetailProvider._(argument: saleId, from: this);

  @override
  String toString() => r'saleDetailProvider';
}

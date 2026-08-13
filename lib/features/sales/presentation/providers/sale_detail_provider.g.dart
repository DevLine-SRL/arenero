// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleDetail)
final saleDetailProvider = SaleDetailFamily._();

final class SaleDetailProvider
    extends $AsyncNotifierProvider<SaleDetail, Sale> {
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
  SaleDetail create() => SaleDetail();

  @override
  bool operator ==(Object other) {
    return other is SaleDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDetailHash() => r'6c9cce49de8b4c77d0ae820d617213a832b5c091';

final class SaleDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          SaleDetail,
          AsyncValue<Sale>,
          Sale,
          FutureOr<Sale>,
          String
        > {
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

abstract class _$SaleDetail extends $AsyncNotifier<Sale> {
  late final _$args = ref.$arg as String;
  String get saleId => _$args;

  FutureOr<Sale> build(String saleId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Sale>, Sale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Sale>, Sale>,
              AsyncValue<Sale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

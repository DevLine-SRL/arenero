// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sellers_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SellersController)
final sellersControllerProvider = SellersControllerProvider._();

final class SellersControllerProvider
    extends $NotifierProvider<SellersController, List<Seller>> {
  SellersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellersControllerHash();

  @$internal
  @override
  SellersController create() => SellersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Seller> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Seller>>(value),
    );
  }
}

String _$sellersControllerHash() => r'cdc403d9fa7e4c6eb8d1277db2ece84ee808786a';

abstract class _$SellersController extends $Notifier<List<Seller>> {
  List<Seller> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Seller>, List<Seller>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Seller>, List<Seller>>,
              List<Seller>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

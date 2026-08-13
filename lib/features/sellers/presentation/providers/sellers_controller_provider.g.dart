// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sellers_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SellersController)
final sellersControllerProvider = SellersControllerProvider._();

final class SellersControllerProvider
    extends $AsyncNotifierProvider<SellersController, List<Seller>> {
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
}

String _$sellersControllerHash() => r'85973ce73c48bd4b16e374b3e38c79fd8de65a32';

abstract class _$SellersController extends $AsyncNotifier<List<Seller>> {
  FutureOr<List<Seller>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Seller>>, List<Seller>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Seller>>, List<Seller>>,
              AsyncValue<List<Seller>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

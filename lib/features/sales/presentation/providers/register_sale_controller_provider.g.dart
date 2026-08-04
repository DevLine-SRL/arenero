// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_sale_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegisterSaleController)
final registerSaleControllerProvider = RegisterSaleControllerProvider._();

final class RegisterSaleControllerProvider
    extends $NotifierProvider<RegisterSaleController, RegisterSaleState> {
  RegisterSaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerSaleControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerSaleControllerHash();

  @$internal
  @override
  RegisterSaleController create() => RegisterSaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterSaleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterSaleState>(value),
    );
  }
}

String _$registerSaleControllerHash() =>
    r'9224c3e2e86c548712962bbbb4a0eff74d06969c';

abstract class _$RegisterSaleController extends $Notifier<RegisterSaleState> {
  RegisterSaleState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RegisterSaleState, RegisterSaleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegisterSaleState, RegisterSaleState>,
              RegisterSaleState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

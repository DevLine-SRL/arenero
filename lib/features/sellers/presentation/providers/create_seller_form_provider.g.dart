// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_seller_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateSellerForm)
final createSellerFormProvider = CreateSellerFormProvider._();

final class CreateSellerFormProvider
    extends $NotifierProvider<CreateSellerForm, CreateSellerFormState> {
  CreateSellerFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSellerFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSellerFormHash();

  @$internal
  @override
  CreateSellerForm create() => CreateSellerForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSellerFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSellerFormState>(value),
    );
  }
}

String _$createSellerFormHash() => r'1ef006556a1da6d8c29c07037b89e66e1d43b88d';

abstract class _$CreateSellerForm extends $Notifier<CreateSellerFormState> {
  CreateSellerFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreateSellerFormState, CreateSellerFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateSellerFormState, CreateSellerFormState>,
              CreateSellerFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_client_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `CreateClientFormState.copyWith` borra los mensajes de error que no recibe,
/// para poder limpiarlos pasando `null`. Por eso cada método de aquí declara
/// los tres errores: así se ve en el sitio qué queda y qué se limpia, sin
/// depender de un valor por defecto escondido.

@ProviderFor(CreateClientForm)
final createClientFormProvider = CreateClientFormProvider._();

/// `CreateClientFormState.copyWith` borra los mensajes de error que no recibe,
/// para poder limpiarlos pasando `null`. Por eso cada método de aquí declara
/// los tres errores: así se ve en el sitio qué queda y qué se limpia, sin
/// depender de un valor por defecto escondido.
final class CreateClientFormProvider
    extends $NotifierProvider<CreateClientForm, CreateClientFormState> {
  /// `CreateClientFormState.copyWith` borra los mensajes de error que no recibe,
  /// para poder limpiarlos pasando `null`. Por eso cada método de aquí declara
  /// los tres errores: así se ve en el sitio qué queda y qué se limpia, sin
  /// depender de un valor por defecto escondido.
  CreateClientFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createClientFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createClientFormHash();

  @$internal
  @override
  CreateClientForm create() => CreateClientForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateClientFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateClientFormState>(value),
    );
  }
}

String _$createClientFormHash() => r'8420769d12f37ba5adfde4f9797174c5596abe44';

/// `CreateClientFormState.copyWith` borra los mensajes de error que no recibe,
/// para poder limpiarlos pasando `null`. Por eso cada método de aquí declara
/// los tres errores: así se ve en el sitio qué queda y qué se limpia, sin
/// depender de un valor por defecto escondido.

abstract class _$CreateClientForm extends $Notifier<CreateClientFormState> {
  CreateClientFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreateClientFormState, CreateClientFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateClientFormState, CreateClientFormState>,
              CreateClientFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

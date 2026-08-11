// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgotPasswordForm)
final forgotPasswordFormProvider = ForgotPasswordFormProvider._();

final class ForgotPasswordFormProvider
    extends $NotifierProvider<ForgotPasswordForm, ForgotPasswordFormState> {
  ForgotPasswordFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordFormHash();

  @$internal
  @override
  ForgotPasswordForm create() => ForgotPasswordForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotPasswordFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotPasswordFormState>(value),
    );
  }
}

String _$forgotPasswordFormHash() =>
    r'4bf7812b3c8c2e86cd99342dca9677423ee3fdcb';

abstract class _$ForgotPasswordForm extends $Notifier<ForgotPasswordFormState> {
  ForgotPasswordFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ForgotPasswordFormState, ForgotPasswordFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForgotPasswordFormState, ForgotPasswordFormState>,
              ForgotPasswordFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

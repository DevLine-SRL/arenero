// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginForm)
final loginFormProvider = LoginFormProvider._();

final class LoginFormProvider
    extends $NotifierProvider<LoginForm, LoginFormState> {
  LoginFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginFormHash();

  @$internal
  @override
  LoginForm create() => LoginForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormState>(value),
    );
  }
}

String _$loginFormHash() =>
    r'5425d082dae1c83cb2ba2e4f2d10c8bbc49a2505';

abstract class _$LoginForm extends $Notifier<LoginFormState> {
  LoginFormState build();

  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;

    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormState, LoginFormState>,
              LoginFormState,
              Object?,
              Object?
            >;

    return element.handleCreate(ref, build);
  }
}
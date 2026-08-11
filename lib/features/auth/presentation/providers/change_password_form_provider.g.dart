// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChangePasswordForm)
final changePasswordFormProvider = ChangePasswordFormProvider._();

final class ChangePasswordFormProvider
    extends $NotifierProvider<ChangePasswordForm, ChangePasswordFormState> {
  ChangePasswordFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordFormHash();

  @$internal
  @override
  ChangePasswordForm create() => ChangePasswordForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordFormState>(value),
    );
  }
}

String _$changePasswordFormHash() =>
    r'82b162e256bad05073c5736a454eaa4ebae6423e';

abstract class _$ChangePasswordForm extends $Notifier<ChangePasswordFormState> {
  ChangePasswordFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ChangePasswordFormState, ChangePasswordFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChangePasswordFormState, ChangePasswordFormState>,
              ChangePasswordFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

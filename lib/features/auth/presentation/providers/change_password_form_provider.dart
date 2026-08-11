import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/validators/validators.dart';
import '../../../../shared/value_objects/password.dart';
import 'auth_providers.dart';
import 'change_password_form_state.dart';

part 'change_password_form_provider.g.dart';

@riverpod
class ChangePasswordForm extends _$ChangePasswordForm {
  @override
  ChangePasswordFormState build() => const ChangePasswordFormState();

  void onPasswordChanged(String value) {
    final result = Password.create(value);

    state = state.copyWith(
      password: value,
      passwordError: result.fold((failure) => failure.message, (_) => null),
      confirmationError: _confirmationError(value, state.confirmation),
      submitError: null,
    );
  }

  void onConfirmationChanged(String value) {
    state = state.copyWith(
      confirmation: value,
      confirmationError: _confirmationError(state.password, value),
      submitError: null,
    );
  }

  String? _confirmationError(String password, String confirmation) {
    if (confirmation.isEmpty) return required(confirmation);
    if (confirmation != password) return 'Las contraseñas no coinciden';
    return null;
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final useCase = ref.read(changePasswordUseCaseProvider);
    final result = await useCase(rawPassword: state.password);

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        submitError: failure.message,
      ),
      (_) => state = state.copyWith(isSubmitting: false, isSuccess: true),
    );
  }
}
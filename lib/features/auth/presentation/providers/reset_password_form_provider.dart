import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/value_objects/email.dart';
import 'auth_providers.dart';
import 'reset_password_form_state.dart';

part 'reset_password_form_provider.g.dart';

@riverpod
class ResetPasswordForm extends _$ResetPasswordForm {
  @override
  ResetPasswordFormState build() => const ResetPasswordFormState();

  void onEmailChanged(String value) {
    final result = Email.create(value);

    state = state.copyWith(
      email: value,
      emailError: result.fold((failure) => failure.message, (_) => null),
      submitError: null,
      isSuccess: false,
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final useCase = ref.read(resetPasswordUseCaseProvider);
    final result = await useCase(rawEmail: state.email);

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        submitError: failure.message,
      ),
      (_) => state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      ),
    );
  }
}
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/value_objects/email.dart';
import '../../../../shared/value_objects/verification_code.dart';
import 'auth_providers.dart';
import 'forgot_password_state.dart';

part 'forgot_password_form_provider.g.dart';

@riverpod
class ForgotPasswordForm extends _$ForgotPasswordForm {
  @override
  ForgotPasswordFormState build() => const ForgotPasswordFormState();

  void onEmailChanged(String value) {
    final result = Email.create(value);

    state = state.copyWith(
      email: value,
      emailError: result.fold((failure) => failure.message, (_) => null),
      submitEmailError: null,
    );
  }

  void onCodeChanged(String value) {
    final result = VerificationCode.create(value);

    state = state.copyWith(
      code: value,
      codeError: result.fold((failure) => failure.message, (_) => null),
      submitCodeError: null,
    );
  }

  Future<void> submitEmail() async {
    if (!state.isEmailValid || state.isLoadingEmail) return;

    state = state.copyWith(isLoadingEmail: true, submitEmailError: null);

    final useCase = ref.read(sendForgotPasswordCodeUseCaseProvider);
    final result = await useCase(rawEmail: state.email);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingEmail: false,
        submitEmailError: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoadingEmail: false,
        step: ForgotPasswordStep.code,
      ),
    );
  }

  Future<void> submitCode() async {
    if (!state.isCodeValid || state.isLoadingCode) return;

    state = state.copyWith(isLoadingCode: true, submitCodeError: null);

    final useCase = ref.read(verifyForgotPasswordCodeUseCaseProvider);
    final result = await useCase(rawEmail: state.email, rawCode: state.code);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingCode: false,
        submitCodeError: failure.message,
      ),
      (_) => state = state.copyWith(isLoadingCode: false, isVerified: true),
    );
  }
}

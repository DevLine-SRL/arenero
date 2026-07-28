import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/validators/validators.dart';
import '../../domain/value_objects/email.dart';
import 'auth_providers.dart';
import 'login_form_state.dart';

part 'login_form_provider.g.dart';

@riverpod
class LoginForm extends _$LoginForm {
  @override
  LoginFormState build() => const LoginFormState();

  void onEmailChanged(String value) {
    final result = Email.create(value);

    state = state.copyWith(
      email: value,
      emailError: result.fold((failure) => failure.message, (_) => null),
      submitError: null,
    );
  }

  void onPasswordChanged(String value) {
    final error = required(value);

    state = state.copyWith(
      password: value,
      passwordError: error,
      submitError: null
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(
      rawEmail: state.email,
      rawPassword: state.password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        submitError: failure.message,
      ),
      (user) => state = state.copyWith(isSubmitting: false),
    );
  }
}

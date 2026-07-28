import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/validators/validators.dart';

part 'login_form_provider.g.dart';

class LoginFormState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  bool get isValid => emailError == null && passwordError == null && email != '' && password != '';
}

@riverpod
class LoginFormNotifier extends _$LoginFormNotifier {
  @override
  LoginFormState build() => const LoginFormState();

  void onEmailChanged(String value) {
    final error = required(value) ?? email(value);

    state = LoginFormState(
      email: value,
      password: state.password,
      emailError: error,
      passwordError: state.passwordError,
    );
  }

  void onPasswordChanged(String value) {
    final error = required(value);

    state = LoginFormState(
      email: state.email,
      password: value,
      emailError: state.emailError,
      passwordError: error,
    );
  }
}

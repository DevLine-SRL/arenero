class LoginFormState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final String? submitError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    this.submitError,
  });

  bool get isValid =>
    emailError == null &&
    passwordError == null &&
    email != '' &&
    password != '';

  LoginFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? isSubmitting,
    String? submitError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}

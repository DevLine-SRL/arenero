class LoginFormState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final String? submitError;
  final bool isLocked;
  final Duration? lockRemaining;
  final int? attemptsLeft;
  final int? maxAttempts;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    this.submitError,
    this.isLocked = false,
    this.lockRemaining,
    this.attemptsLeft,
    this.maxAttempts,
  });

  bool get isValid => emailError == null && passwordError == null;

  LoginFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? isSubmitting,
    String? submitError,
    bool? isLocked,
    Duration? lockRemaining,
    int? attemptsLeft,
    int? maxAttempts,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
      isLocked: isLocked ?? this.isLocked,
      lockRemaining: lockRemaining,
      attemptsLeft: attemptsLeft,
      maxAttempts: maxAttempts,
    );
  }
}

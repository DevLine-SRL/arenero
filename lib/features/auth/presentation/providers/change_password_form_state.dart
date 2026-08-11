class ChangePasswordFormState {
  final String password;
  final String? passwordError;
  final String confirmation;
  final String? confirmationError;
  final bool isSubmitting;
  final String? submitError;
  final bool isSuccess;

  const ChangePasswordFormState({
    this.password = '',
    this.passwordError,
    this.confirmation = '',
    this.confirmationError,
    this.isSubmitting = false,
    this.submitError,
    this.isSuccess = false,
  });

  bool get isValid =>
      passwordError == null &&
      confirmationError == null &&
      password != '' &&
      confirmation != '';

  ChangePasswordFormState copyWith({
    String? password,
    String? passwordError,
    String? confirmation,
    String? confirmationError,
    bool? isSubmitting,
    String? submitError,
    bool? isSuccess,
  }) {
    return ChangePasswordFormState(
      password: password ?? this.password,
      passwordError: passwordError,
      confirmation: confirmation ?? this.confirmation,
      confirmationError: confirmationError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

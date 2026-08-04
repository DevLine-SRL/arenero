class ResetPasswordFormState {
  final String email;
  final String? emailError;
  final bool isSubmitting;
  final String? submitError;
  final bool isSuccess;
  const ResetPasswordFormState({
    this.email = '',
    this.emailError,
    this.isSubmitting = false,
    this.submitError,
    this.isSuccess = false,
  });
  bool get isValid => emailError == null && email.isNotEmpty;
  ResetPasswordFormState copyWith({
    String? email,
    String? emailError,
    bool? isSubmitting,
    String? submitError,
    bool? isSuccess,
  }) {
    return ResetPasswordFormState(
      email: email ?? this.email,
      emailError: emailError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
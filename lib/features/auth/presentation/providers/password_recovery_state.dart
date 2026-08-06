class PasswordRecoveryState {
  static const Object _notProvided = Object();

  final String email;
  final String? emailError;
  final bool isSubmitting;
  final bool isSuccess;
  final String? message;

  const PasswordRecoveryState({
    this.email = '',
    this.emailError,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.message,
  });

  bool get isValid {
    return email.trim().isNotEmpty && emailError == null;
  }

  PasswordRecoveryState copyWith({
    String? email,
    Object? emailError = _notProvided,
    bool? isSubmitting,
    bool? isSuccess,
    Object? message = _notProvided,
  }) {
    return PasswordRecoveryState(
      email: email ?? this.email,
      emailError: identical(emailError, _notProvided)
          ? this.emailError
          : emailError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      message: identical(message, _notProvided)
          ? this.message
          : message as String?,
    );
  }
}
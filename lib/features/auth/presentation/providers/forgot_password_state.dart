enum ForgotPasswordStep { email, code }

class ForgotPasswordFormState {
  final ForgotPasswordStep step;

  // Paso 1: email
  final String email;
  final String? emailError;
  final bool isLoadingEmail;
  final String? submitEmailError;

  // Paso 2: código
  final String code;
  final String? codeError;
  final bool isLoadingCode;
  final String? submitCodeError;
  final bool isVerified;

  const ForgotPasswordFormState({
    this.step = ForgotPasswordStep.email,
    this.email = '',
    this.emailError,
    this.isLoadingEmail = false,
    this.submitEmailError,
    this.code = '',
    this.codeError,
    this.isLoadingCode = false,
    this.submitCodeError,
    this.isVerified = false,
  });

  bool get isEmailValid => emailError == null && email != '';
  bool get isCodeValid => codeError == null && code != '';

  ForgotPasswordFormState copyWith({
    ForgotPasswordStep? step,
    String? email,
    String? emailError,
    bool? isLoadingEmail,
    String? submitEmailError,
    String? code,
    String? codeError,
    bool? isLoadingCode,
    String? submitCodeError,
    bool? isVerified,
  }) {
    return ForgotPasswordFormState(
      step: step ?? this.step,
      email: email ?? this.email,
      emailError: emailError,
      isLoadingEmail: isLoadingEmail ?? this.isLoadingEmail,
      submitEmailError: submitEmailError,
      code: code ?? this.code,
      codeError: codeError,
      isLoadingCode: isLoadingCode ?? this.isLoadingCode,
      submitCodeError: submitCodeError,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class CreateSellerFormState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isSubmitting;
  final String? submitError;

  const CreateSellerFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isSubmitting = false,
    this.submitError,
  });

  bool get isValid =>
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null &&
      name != '' &&
      email != '' &&
      password != '' &&
      confirmPassword != '';

  CreateSellerFormState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool? isSubmitting,
    String? submitError,
  }) {
    return CreateSellerFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}

class CreateClientFormState {
  final String name;
  final String ci;
  final String phone;
  final String nit;
  final String? nameError;
  final String? ciError;
  final String? phoneError;
  final String? nitError;

  /// La comprobación de cédula duplicada está en curso. Bloquea el envío para
  /// no registrar mientras no se sabe.
  final bool isCheckingCi;

  final bool isSubmitting;
  final String? submitError;

  const CreateClientFormState({
    this.name = '',
    this.ci = '',
    this.phone = '',
    this.nit = '',
    this.nameError,
    this.ciError,
    this.phoneError,
    this.nitError,
    this.isCheckingCi = false,
    this.isSubmitting = false,
    this.submitError,
  });

  bool get isValid =>
      nameError == null &&
      ciError == null &&
      phoneError == null &&
      nitError == null &&
      name.trim() != '' &&
      ci.trim() != '';

  bool get canSubmit => isValid && !isSubmitting && !isCheckingCi;

  /// Los campos de error se asignan directo, sin `??`, para poder limpiarlos
  /// pasando `null`. Es el mismo criterio que `CreateSellerFormState`.
  CreateClientFormState copyWith({
    String? name,
    String? ci,
    String? phone,
    String? nit,
    String? nameError,
    String? ciError,
    String? phoneError,
    String? nitError,
    bool? isCheckingCi,
    bool? isSubmitting,
    String? submitError,
  }) {
    return CreateClientFormState(
      name: name ?? this.name,
      ci: ci ?? this.ci,
      phone: phone ?? this.phone,
      nit: nit ?? this.nit,
      nameError: nameError,
      ciError: ciError,
      phoneError: phoneError,
      nitError: nitError,
      isCheckingCi: isCheckingCi ?? this.isCheckingCi,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}

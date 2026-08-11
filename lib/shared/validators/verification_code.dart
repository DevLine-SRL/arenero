String? verificationCode(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El código es requerido';
  }
  if (value.trim().length != 6) {
    return 'El código debe tener 6 dígitos';
  }
  if (int.tryParse(value.trim()) == null) {
    return 'El código solo debe contener números';
  }
  return null;
}

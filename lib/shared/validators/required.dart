String? required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es requerido';
  }
  return null;
}

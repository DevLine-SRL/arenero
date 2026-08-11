final _fullNameRegExp = RegExp(
  r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?:[ '-][A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$",
);

String? fullName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El nombre es requerido';
  }
  final normalized = collapseSpaces(value);
  if (normalized.length < 2 || normalized.length > 60) {
    return 'El nombre debe tener entre 2 y 60 caracteres';
  }
  if (!_fullNameRegExp.hasMatch(normalized)) {
    return 'El nombre solo puede contener letras, espacios y guiones';
  }
  return null;
}

String collapseSpaces(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

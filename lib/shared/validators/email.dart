final _emailRegExp = RegExp(
  r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
);

String? email(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El correo es requerido';
  }
  if (!_emailRegExp.hasMatch(value.trim())) {
    return 'Correo no válido';
  }
  return null;
}

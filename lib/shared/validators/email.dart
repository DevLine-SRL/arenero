final _emailRegExp = RegExp(
  r'^[a-zA-Z0-9]+(?:[._%+-][a-zA-Z0-9]+)*'
  r'@'
  r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+'
  r'[a-zA-Z]{2,63}$'
);

String? email(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El correo es requerido';
  }
  final trimmed = value.trim();
  if (trimmed.length > 254) {
    return 'El correo es demasiado largo';
  }
  final atIndex = trimmed.indexOf('@');
  if (atIndex > 64) {
    return 'La parte local del correo es demasiado larga';
  }
  if (!_emailRegExp.hasMatch(trimmed)) {
    return 'Correo no válido';
  }
  return null;
}

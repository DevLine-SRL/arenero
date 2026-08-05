/// Cédula de identidad boliviana: de 5 a 10 dígitos, con complemento opcional
/// de una o dos posiciones alfanuméricas (por ejemplo `1234567-1A`).
final _ciRegExp = RegExp(r'^\d{5,10}(-[A-Za-z0-9]{1,2})?$');

String? ci(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'La cédula de identidad es requerida';
  }
  if (!_ciRegExp.hasMatch(value.trim())) {
    return 'Cédula no válida. Usa de 5 a 10 dígitos, con complemento opcional';
  }
  return null;
}

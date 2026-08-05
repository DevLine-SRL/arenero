/// Teléfono boliviano: 7 dígitos para fijo, 8 para celular. Se admiten
/// espacios y guiones al escribir; se ignoran al validar.
final _phoneRegExp = RegExp(r'^\d{7,8}$');

/// El teléfono es opcional: vacío es válido. Para exigirlo, combina con
/// `required`.
String? phone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final digits = value.replaceAll(RegExp(r'[\s-]'), '');
  if (!_phoneRegExp.hasMatch(digits)) {
    return 'Teléfono no válido. Debe tener 7 u 8 dígitos';
  }
  return null;
}

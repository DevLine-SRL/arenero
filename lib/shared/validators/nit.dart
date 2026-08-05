/// NIT boliviano: solo dígitos, entre 5 y 15 posiciones.
final _nitRegExp = RegExp(r'^\d{5,15}$');

/// El NIT es opcional: vacío es válido. Para exigirlo, combina con `required`.
String? nit(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  if (!_nitRegExp.hasMatch(value.trim())) {
    return 'NIT no válido. Debe tener entre 5 y 15 dígitos';
  }
  return null;
}

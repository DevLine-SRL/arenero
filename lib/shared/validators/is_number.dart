import 'validator_type.dart';

String? isNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es requerido';
  }
  if (num.tryParse(value.trim()) == null) {
    return 'Debe ser un número';
  }
  return null;
}

Validator<num> min(num minimum) {
  return (value) {
    if (value < minimum) {
      return 'Debe ser mayor o igual a $minimum';
    }
    return null;
  };
}

Validator<num> max(num maximum) {
  return (value) {
    if (value > maximum) {
      return 'Debe ser menor o igual a $maximum';
    }
    return null;
  };
}

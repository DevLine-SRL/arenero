import 'validator_type.dart';

Validator<String> minLength(int min) {
  return (value) {
    if (value.trim().length < min) {
      return 'Debe tener al menos $min caracteres';
    }
    return null;
  };
}

Validator<String> maxLength(int max) {
  return (value) {
    if (value.trim().length > max) {
      return 'Debe tener máximo $max caracteres';
    }
    return null;
  };
}

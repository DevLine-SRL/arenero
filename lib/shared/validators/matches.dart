import 'validator_type.dart';

Validator<String> matches(RegExp regex, {String message = 'Formato no válido'}) {
  return (value) {
    if (!regex.hasMatch(value.trim())) {
      return message;
    }
    return null;
  };
}

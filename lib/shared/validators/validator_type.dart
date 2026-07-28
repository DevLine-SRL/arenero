typedef Validator<T> = String? Function(T value);

String? compose<T>(Iterable<Validator<T>> validators, T value) {
  for (final validator in validators) {
    final error = validator(value);
    if (error != null) return error;
  }
  return null;
}

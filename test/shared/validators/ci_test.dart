import 'package:arenero/shared/validators/ci.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ci', () {
    test('accepts a plain identity card number', () {
      expect(ci('1234567'), isNull);
    });

    test('accepts the shortest and longest allowed lengths', () {
      expect(ci('12345'), isNull);
      expect(ci('1234567890'), isNull);
    });

    test('accepts an optional alphanumeric complement', () {
      expect(ci('1234567-1A'), isNull);
      expect(ci('1234567-A'), isNull);
    });

    test('trims surrounding whitespace before validating', () {
      expect(ci('  1234567  '), isNull);
    });

    test('rejects an empty value', () {
      expect(ci(''), 'La cédula de identidad es requerida');
      expect(ci('   '), 'La cédula de identidad es requerida');
      expect(ci(null), 'La cédula de identidad es requerida');
    });

    test('rejects a number that is too short or too long', () {
      expect(ci('1234'), isNotNull);
      expect(ci('12345678901'), isNotNull);
    });

    test('rejects letters outside the complement', () {
      expect(ci('12A4567'), isNotNull);
    });

    test('rejects a complement longer than two characters', () {
      expect(ci('1234567-1AB'), isNotNull);
    });
  });
}

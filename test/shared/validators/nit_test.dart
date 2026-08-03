import 'package:arenero/shared/validators/nit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nit', () {
    test('treats an empty value as valid because the field is optional', () {
      expect(nit(''), isNull);
      expect(nit('   '), isNull);
      expect(nit(null), isNull);
    });

    test('accepts the shortest and longest allowed lengths', () {
      expect(nit('12345'), isNull);
      expect(nit('123456789012345'), isNull);
    });

    test('trims surrounding whitespace before validating', () {
      expect(nit('  1234567  '), isNull);
    });

    test('rejects a number that is too short or too long', () {
      expect(nit('1234'), isNotNull);
      expect(nit('1234567890123456'), isNotNull);
    });

    test('rejects anything that is not digits', () {
      expect(nit('12345-6'), isNotNull);
      expect(nit('1234A'), isNotNull);
    });
  });
}

import 'package:arenero/shared/validators/phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phone', () {
    test('treats an empty value as valid because the field is optional', () {
      expect(phone(''), isNull);
      expect(phone('   '), isNull);
      expect(phone(null), isNull);
    });

    test('accepts a 7 digit landline and an 8 digit mobile', () {
      expect(phone('4441234'), isNull);
      expect(phone('70011223'), isNull);
    });

    test('ignores spaces and dashes', () {
      expect(phone('700-112-23'), isNull);
      expect(phone('700 112 23'), isNull);
    });

    test('rejects a number with the wrong length', () {
      expect(phone('123456'), isNotNull);
      expect(phone('123456789'), isNotNull);
    });

    test('rejects a number containing letters', () {
      expect(phone('7001122A'), isNotNull);
    });
  });
}

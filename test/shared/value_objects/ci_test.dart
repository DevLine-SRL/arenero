import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/shared/value_objects/ci.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ci.create', () {
    test('returns a Ci for a valid identity card number', () {
      final result = Ci.create('1234567');

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => throw StateError('expected a Ci')).value,
        '1234567',
      );
    });

    test('stores the trimmed value', () {
      final result = Ci.create('  1234567  ');

      expect(
        result.getOrElse(() => throw StateError('expected a Ci')).value,
        '1234567',
      );
    });

    test('returns a ValidationFailure for an invalid number', () {
      final result = Ci.create('12A');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected a failure'),
      );
    });
  });
}

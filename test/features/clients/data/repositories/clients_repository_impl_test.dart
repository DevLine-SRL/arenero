import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:arenero/shared/value_objects/ci.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../support/fakes/fake_clients_remote_datasource.dart';

Ci _ci(String value) {
  return Ci.create(value).getOrElse(() => throw StateError('invalid ci'));
}

Failure _failureOf(dynamic result) {
  return result.fold(
    (failure) => failure as Failure,
    (_) => fail('expected a Left, got a Right'),
  );
}

void main() {
  late FakeClientsRemoteDataSource dataSource;
  late ClientsRepositoryImpl repository;

  setUp(() {
    dataSource = FakeClientsRemoteDataSource();
    repository = ClientsRepositoryImpl(dataSource);
  });

  group('createClient', () {
    test('passes the raw ci value down to the data source', () async {
      await repository.createClient(
        name: 'Juan Pérez',
        ci: _ci('1234567'),
        phone: '70011223',
      );

      expect(dataSource.lastCreatedCi, '1234567');
      expect(dataSource.lastCreatedName, 'Juan Pérez');
    });

    test('maps a duplicated ci to a ValidationFailure on the ci field', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message:
            'duplicate key value violates unique constraint "clients_ci_unique"',
        code: '23505',
      );

      final failure = _failureOf(
        await repository.createClient(name: 'Juan', ci: _ci('1234567')),
      );

      expect(failure, isA<ValidationFailure>());
      expect(
        (failure as ValidationFailure).errors,
        containsPair('ci', isNotNull),
      );
      expect(failure.message, contains('Ya existe un cliente'));
    });

    test(
      'maps a unique violation on another constraint to a generic message',
      () async {
        dataSource.errorToThrow = supabase.PostgrestException(
          message: 'duplicate key value violates unique constraint "other_key"',
          code: '23505',
        );

        final failure = _failureOf(
          await repository.createClient(name: 'Juan', ci: _ci('1234567')),
        );

        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).errors, isNull);
      },
    );

    test('maps an rls rejection to UnauthorizedFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'new row violates row-level security policy',
        code: '42501',
      );

      final failure = _failureOf(
        await repository.createClient(name: 'Juan', ci: _ci('1234567')),
      );

      expect(failure, isA<UnauthorizedFailure>());
    });

    test(
      'maps an unknown error to UnexpectedFailure keeping the code',
      () async {
        dataSource.errorToThrow = supabase.PostgrestException(
          message: 'something else went wrong',
          code: '08006',
        );

        final failure = _failureOf(
          await repository.createClient(name: 'Juan', ci: _ci('1234567')),
        );

        expect(failure, isA<UnexpectedFailure>());
        expect(failure.code, '08006');
      },
    );

    test('never lets a non-postgrest exception escape', () async {
      dataSource.errorToThrow = StateError('boom');

      final failure = _failureOf(
        await repository.createClient(name: 'Juan', ci: _ci('1234567')),
      );

      expect(failure, isA<UnexpectedFailure>());
    });
  });

  group('searchClients', () {
    test('forwards the query and the inactive flag', () async {
      await repository.searchClients(query: 'juan', includeInactive: true);

      expect(dataSource.lastSearchQuery, 'juan');
      expect(dataSource.lastIncludeInactive, isTrue);
    });

    test('excludes inactive clients by default', () async {
      await repository.searchClients(query: '');

      expect(dataSource.lastIncludeInactive, isFalse);
    });

    test('maps a missing row to NotFoundFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'no rows returned',
        code: 'PGRST116',
      );

      final failure = _failureOf(await repository.searchClients(query: 'x'));

      expect(failure, isA<NotFoundFailure>());
    });
  });

  group('existsByCi', () {
    test('returns true when the data source finds a row', () async {
      dataSource.existsResult = true;

      final result = await repository.existsByCi(_ci('1234567'));

      expect(result.getOrElse(() => false), isTrue);
    });

    test('returns false when the data source finds nothing', () async {
      dataSource.existsResult = false;

      final result = await repository.existsByCi(_ci('1234567'));

      expect(result.getOrElse(() => true), isFalse);
    });
  });
}

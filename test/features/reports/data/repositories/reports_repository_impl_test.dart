import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:arenero/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_reports_remote_datasource.dart';

Failure _failureOf(dynamic result) {
  return result.fold(
    (failure) => failure as Failure,
    (_) => fail('expected a Left, got a Right'),
  );
}

void main() {
  late FakeReportsRemoteDataSource dataSource;
  late ReportsRepositoryImpl repository;

  setUp(() {
    dataSource = FakeReportsRemoteDataSource();
    repository = ReportsRepositoryImpl(dataSource);
  });

  group('getPeriodSummary', () {
    test('returns the summary on success', () async {
      final result = await repository.getPeriodSummary(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 31),
      );

      final summary = result.fold(
        (failure) => fail('expected a Right, got $failure'),
        (summary) => summary,
      );
      expect(summary.nSales, 1);
      expect(summary.totalSold, 100);
    });

    test('maps a denied read to an UnauthorizedFailure', () async {
      dataSource.errorToThrow = ReportsRemoteException(
        message: 'permission denied for function period_summary',
        code: '42501',
      );

      final failure = _failureOf(
        await repository.getPeriodSummary(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 31),
        ),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, contains('No tienes permisos'));
    });

    test('maps an unknown postgrest code to an UnexpectedFailure', () async {
      dataSource.errorToThrow = ReportsRemoteException(
        message: 'boom',
        code: '08006',
      );

      final failure = _failureOf(
        await repository.getPeriodSummary(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 31),
        ),
      );

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.code, '08006');
    });

    test('maps a server error without code to an UnexpectedFailure', () async {
      dataSource.errorToThrow = const ReportsRemoteException(message: 'boom');

      final failure = _failureOf(
        await repository.getPeriodSummary(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 31),
        ),
      );

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'boom');
    });
  });

  group('getSaleDetails', () {
    test('returns items and total count on success', () async {
      final result = await repository.getSaleDetails(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 31),
        clientId: 'client-1',
        page: 2,
        pageSize: 8,
      );

      final page = result.fold(
        (failure) => fail('expected a Right, got $failure'),
        (page) => page,
      );
      expect(page.items, isEmpty);
      expect(page.totalCount, 0);
    });

    test('maps a denied read to an UnauthorizedFailure', () async {
      dataSource.errorToThrow = ReportsRemoteException(
        message: 'permission denied',
        code: '42501',
      );

      final failure = _failureOf(
        await repository.getSaleDetails(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 31),
          clientId: 'client-1',
          page: 0,
        ),
      );

      expect(failure, isA<UnauthorizedFailure>());
    });

    test('maps a server error without code to an UnexpectedFailure', () async {
      dataSource.errorToThrow = const ReportsRemoteException(message: 'boom');

      final failure = _failureOf(
        await repository.getSaleDetails(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 31),
          clientId: 'client-1',
          page: 0,
        ),
      );

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, 'boom');
    });
  });
}

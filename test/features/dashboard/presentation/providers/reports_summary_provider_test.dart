import 'dart:async';

import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/dashboard/presentation/providers/reports_date_range_provider.dart';
import 'package:arenero/features/dashboard/presentation/providers/reports_providers.dart';
import 'package:arenero/features/dashboard/presentation/providers/reports_summary_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/report_builders.dart';
import '../../../../support/fakes/fake_reports_repository.dart';

void main() {
  late FakeReportsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeReportsRepository();
    container = ProviderContainer(
      overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    container.listen(reportsSummaryProvider, (_, _) {});
    container.read(reportsDateRangeProvider.notifier)
      ..onStartChanged(DateTime(2026, 8, 1))
      ..onEndChanged(DateTime(2026, 8, 31));
  });

  group('reportsSummaryProvider', () {
    test(
      'combines the period summary with the top clients and sellers',
      () async {
        repository.periodSummaryResult = Right(
          buildPeriodSummary(nSales: 4, totalSold: 1000, avgTicket: 250),
        );
        repository.reportByClientResult = Right([
          buildClientReportRow(clientName: 'Cliente A', total: 600),
          buildClientReportRow(clientName: 'Cliente B', total: 400),
        ]);
        repository.reportBySellerResult = Right([
          buildSellerReportRow(sellerName: 'Vendedor A', totalSold: 700),
        ]);

        final data = await container.read(reportsSummaryProvider.future);

        expect(data.period.nSales, 4);
        expect(data.topClients, hasLength(2));
        expect(data.topSellers.single.sellerName, 'Vendedor A');
      },
    );

    test('queries the top reports limited to 3 rows', () async {
      await container.read(reportsSummaryProvider.future);

      expect(repository.lastReportByClientArgs?.limit, 3);
      expect(repository.lastReportBySellerArgs?.limit, 3);
    });

    test('passes the selected date range to the period summary', () async {
      await container.read(reportsSummaryProvider.future);

      expect(repository.lastPeriodSummaryRange?.start, DateTime(2026, 8, 1));
      expect(repository.lastPeriodSummaryRange?.end, DateTime(2026, 8, 31));
    });

    test('surfaces the failure when the period summary fails', () async {
      repository.periodSummaryResult = const Left(
        UnauthorizedFailure(
          message: 'No tienes permisos para ver los reportes.',
        ),
      );
      final error = await _nextError(container);

      expect(error, isA<UnauthorizedFailure>());
      expect(
        (error as UnauthorizedFailure).message,
        'No tienes permisos para ver los reportes.',
      );
    });
  });
}

Future<Object?> _nextError(ProviderContainer container) async {
  final completer = Completer<Object?>();
  container.listen(reportsSummaryProvider, (previous, next) {
    if (next.hasError && !completer.isCompleted) {
      completer.complete(next.error);
    }
  });
  return completer.future.timeout(const Duration(seconds: 5));
}

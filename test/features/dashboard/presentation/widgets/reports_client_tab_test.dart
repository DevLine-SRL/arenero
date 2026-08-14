import 'package:arenero/features/dashboard/presentation/providers/reports_providers.dart';
import 'package:arenero/features/dashboard/presentation/widgets/reports_client_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_reports_repository.dart';

void main() {
  group('ReportsClientTab', () {
    testWidgets('filters the sale details by the selected client', (
      tester,
    ) async {
      final repository = FakeReportsRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: Scaffold(body: ReportsClientTab())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Juan Pérez'), findsOneWidget);
      await tester.tap(find.text('Juan Pérez'));
      await tester.pumpAndSettle();

      expect(repository.lastSaleDetailsArgs?.clientId, 'client-1');
      expect(repository.lastSaleDetailsArgs?.sellerId, isNull);
    });

    testWidgets('does not filter the sale details before selecting a client', (
      tester,
    ) async {
      final repository = FakeReportsRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: Scaffold(body: ReportsClientTab())),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.saleDetailsCallCount, 0);
    });
  });
}

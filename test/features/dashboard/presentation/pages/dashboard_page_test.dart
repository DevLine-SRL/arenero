import 'package:arenero/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:arenero/features/dashboard/presentation/providers/reports_providers.dart';
import 'package:arenero/features/dashboard/presentation/widgets/reports_client_tab.dart';
import 'package:arenero/features/dashboard/presentation/widgets/reports_section_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_reports_repository.dart';

void main() {
  group('DashboardPage', () {
    testWidgets('shows the section selector with Resumen as default', (
      tester,
    ) async {
      await tester.pumpWidget(_pumpPage());
      await tester.pumpAndSettle();

      expect(find.byType(ReportsSectionSelector), findsOneWidget);
      expect(find.text('Resumen'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets(
      'selects a client suggestion from the autocomplete overlay inside an '
      'indexed stack shell',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repository = FakeReportsRepository();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reportsRepositoryProvider.overrideWithValue(repository),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: IndexedStack(
                  index: 3,
                  children: [
                    for (var i = 0; i < 3; i++) const SizedBox.expand(),
                    const DashboardPage(),
                    for (var i = 0; i < 2; i++) const SizedBox.expand(),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open the section picker bottom sheet and select "Cliente".
        await tester.tap(find.byType(ReportsSectionSelector));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cliente'));
        await tester.pumpAndSettle();

        // Interact with the autocomplete field in the client tab.
        await tester.tap(
          find.descendant(
            of: find.byType(ReportsClientTab),
            matching: find.byType(TextField),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Juan Pérez'), findsOneWidget);

        await tester.tap(find.text('Juan Pérez'));
        await tester.pumpAndSettle();

        expect(find.byTooltip('Quitar selección'), findsOneWidget);
        expect(repository.lastSearchClientsQuery, '');
      },
    );
  });
}

Widget _pumpPage() {
  return ProviderScope(
    overrides: [
      reportsRepositoryProvider.overrideWithValue(FakeReportsRepository()),
    ],
    child: const MaterialApp(home: Scaffold(body: DashboardPage())),
  );
}

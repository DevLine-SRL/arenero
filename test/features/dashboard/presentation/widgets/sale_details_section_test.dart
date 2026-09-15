import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/dashboard/presentation/providers/reports_providers.dart';
import 'package:arenero/features/dashboard/presentation/providers/sale_details_page_provider.dart';
import 'package:arenero/features/dashboard/presentation/widgets/sale_details_section.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/report_builders.dart';
import '../../../../support/fakes/fake_reports_repository.dart';

void main() {
  group('SaleDetailsSection', () {
    testWidgets('renders each sale as a card with count and pagination', (
      tester,
    ) async {
      final repository = FakeReportsRepository()
        ..saleDetailsResult = Right(
          buildSaleDetailsPage(
            totalCount: 2,
            items: [
              buildSaleDetailLine(
                number: '15',
                saleDate: DateTime(2026, 8, 13),
                productName: 'Roca Triturada',
                quantity: 3,
                subtotal: 2034,
              ),
              buildSaleDetailLine(
                number: '14',
                saleDate: DateTime(2026, 8, 13),
                productName: 'Arena Gruesa',
                quantity: 2,
                subtotal: 1356,
              ),
            ],
          ),
        );

      await _pump(tester, repository);

      expect(find.text('2 resultados'), findsOneWidget);
      expect(find.text('Roca Triturada'), findsOneWidget);
      expect(find.text('Venta 15 - 13 ago 2026 - Cant. 3'), findsOneWidget);
      expect(find.text('Bs. 2,034'), findsOneWidget);
      expect(find.text('Arena Gruesa'), findsOneWidget);
      expect(find.text('Venta 14 - 13 ago 2026 - Cant. 2'), findsOneWidget);
      expect(find.text('Bs. 1,356'), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no lines', (
      tester,
    ) async {
      final repository = FakeReportsRepository()
        ..saleDetailsResult = Right(
          buildSaleDetailsPage(items: [], totalCount: 0),
        );

      await _pump(tester, repository);

      expect(find.textContaining('No se encontraron ventas'), findsOneWidget);
    });

    testWidgets('shows the error state with retry when loading fails', (
      tester,
    ) async {
      final repository = FakeReportsRepository()
        ..saleDetailsResult = Left(
          NetworkFailure(message: 'Sin conexión a internet'),
        );

      await _pump(tester, repository);

      expect(find.text('Sin conexión a internet'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeReportsRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: Scaffold(
          body: SaleDetailsSection(
            requestBuilder:
                ({
                  required int page,
                  required String orderColumn,
                  required bool ascending,
                  required String search,
                }) {
                  return SaleDetailsRequest(
                    startDate: DateTime(2026, 8, 1),
                    endDate: DateTime(2026, 8, 31),
                    page: page,
                  );
                },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

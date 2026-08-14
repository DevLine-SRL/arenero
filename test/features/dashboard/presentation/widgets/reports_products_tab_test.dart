import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/dashboard/presentation/providers/reports_providers.dart';
import 'package:arenero/features/dashboard/presentation/widgets/reports_products_tab.dart';
import 'package:arenero/features/reports/domain/entities/product_report_row.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes/fake_reports_repository.dart';

void main() {
  group('ReportsProductsTab', () {
    testWidgets('renders each product as a stacked card', (tester) async {
      final repository = FakeReportsRepository()
        ..reportByProductResult = const Right([
          ProductReportRow(
            productUnitId: 'u1',
            productName: 'Arena fina',
            unit: 'm3',
            qtySold: 10,
            totalAmount: 500,
          ),
          ProductReportRow(
            productUnitId: 'u2',
            productName: 'Cemento gris',
            unit: 'bag',
            qtySold: 20,
            totalAmount: 800,
          ),
        ]);

      await _pump(tester, repository);

      expect(find.text('Arena fina'), findsOneWidget);
      expect(find.text('Unidad: m³'), findsOneWidget);
      expect(find.text('Cantidad: 10'), findsOneWidget);
      expect(find.text('Bs. 500'), findsOneWidget);
      expect(find.text('Cemento gris'), findsOneWidget);
      expect(find.text('Unidad: bolsa'), findsOneWidget);
      expect(find.text('Cantidad: 20'), findsOneWidget);
      expect(find.text('Bs. 800'), findsOneWidget);
      expect(find.text('Producto'), findsNothing);
      expect(find.text('Importe total'), findsNothing);
      expect(find.text('Cantidad vendida'), findsNothing);
    });

    testWidgets('sorts products by total amount descending', (tester) async {
      final repository = FakeReportsRepository()
        ..reportByProductResult = const Right([
          ProductReportRow(
            productUnitId: 'u1',
            productName: 'Producto bajo',
            unit: 'kg',
            qtySold: 2,
            totalAmount: 100,
          ),
          ProductReportRow(
            productUnitId: 'u2',
            productName: 'Producto alto',
            unit: 'ton',
            qtySold: 1,
            totalAmount: 900,
          ),
        ]);

      await _pump(tester, repository);

      final alto = find.text('Producto alto');
      final bajo = find.text('Producto bajo');
      expect(tester.getTopLeft(alto).dy, lessThan(tester.getTopLeft(bajo).dy));
    });

    testWidgets('shows the empty state when there are no sales', (
      tester,
    ) async {
      final repository = FakeReportsRepository()
        ..reportByProductResult = const Right([]);

      await _pump(tester, repository);

      expect(find.textContaining('No se encontraron ventas'), findsOneWidget);
    });

    testWidgets('shows the error state with retry when loading fails', (
      tester,
    ) async {
      final repository = FakeReportsRepository()
        ..reportByProductResult = const Left(
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
      child: const MaterialApp(home: Scaffold(body: ReportsProductsTab())),
    ),
  );
  await tester.pumpAndSettle();
}

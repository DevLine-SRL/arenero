import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/sales/domain/entities/sale.dart';
import 'package:arenero/features/sales/domain/entities/sale_delivery.dart';
import 'package:arenero/features/sales/presentation/pages/sale_detail_page.dart';
import 'package:arenero/features/sales/presentation/providers/sales_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../support/builders/sale_builder.dart';
import '../../../../support/fakes/fake_sales_repository.dart';

/// La página usa `context.canPop()`, así que necesita un GoRouter real en el
/// árbol; un MaterialApp pelado no alcanza.
Widget _app(FakeSalesRepository repository) {
  final router = GoRouter(
    initialLocation: '/ventas/historial/sale-1',
    routes: [
      GoRoute(
        path: '/ventas/historial/:id',
        builder: (context, state) =>
            SaleDetailPage(saleId: state.pathParameters['id']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [salesRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late FakeSalesRepository repository;

  setUp(() {
    repository = FakeSalesRepository();
  });

  group('SaleDetailPage', () {
    testWidgets('requests the sale named in the route', (tester) async {
      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(repository.lastRequestedSaleId, 'sale-1');
    });

    testWidgets('shows the sale number, client and seller', (tester) async {
      repository.saleDetailResult = Right(buildSale(number: 12));

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Venta 12'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Ana Vendedora'), findsOneWidget);
    });

    testWidgets('shows the price the line was sold at, not the current one', (
      tester,
    ) async {
      // El catálogo hoy cobra 15 por m³; esta venta se cerró a 10. El detalle
      // tiene que seguir mostrando 10.
      repository.saleDetailResult = Right(
        buildSale(
          total: 20,
          details: [
            buildSaleDetail(
              quantity: 2,
              unitPrice: 10,
              productName: 'Arena fina',
            ),
          ],
        ),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Arena fina'), findsOneWidget);
      expect(find.text('2 m³ × Bs. 10.00'), findsOneWidget);
      expect(find.text('Bs. 15.00'), findsNothing);
    });

    testWidgets('renders the discount and the totals', (tester) async {
      repository.saleDetailResult = Right(
        buildSale(
          total: 45,
          details: [buildSaleDetail(quantity: 5, unitPrice: 10, discount: 5)],
        ),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Descuento Bs. 5.00'), findsOneWidget);
      expect(find.text('-Bs. 5.00'), findsOneWidget);
      expect(find.text('Bs. 45.00'), findsWidgets);
    });

    testWidgets('hides the delivery card on customer pickup', (tester) async {
      repository.saleDetailResult = Right(
        buildSale(deliveryMode: SaleDeliveryMode.customerPickup),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Entrega'), findsOneWidget); // la fila de la cabecera
      expect(find.text('Dirección'), findsNothing);
    });

    testWidgets('shows the delivery data on company delivery', (tester) async {
      repository.saleDetailResult = Right(
        buildSale(
          deliveryMode: SaleDeliveryMode.companyDelivery,
          freightAmount: 30,
          delivery: const SaleDelivery(vehiclePlate: '1234-ABC'),
        ),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      // La tarjeta de entrega cae fuera del viewport de la prueba y el
      // ListView no la construye hasta que se desplaza.
      await tester.scrollUntilVisible(
        find.text('1234-ABC'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('1234-ABC'), findsOneWidget);
      expect(find.text('+Bs. 30.00'), findsOneWidget);
      expect(find.text('Fecha de entrega'), findsNothing);
      expect(find.text('Dirección'), findsNothing);
    });

    testWidgets('hides the notes card when the sale has none', (tester) async {
      repository.saleDetailResult = Right(buildSale());

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Notas'), findsNothing);
    });

    testWidgets('shows the failure message and a retry button', (tester) async {
      repository.saleDetailResult = const Left(
        NotFoundFailure(message: 'La venta no existe.'),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('La venta no existe.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('falls back when the product name is missing', (tester) async {
      repository.saleDetailResult = Right(
        buildSale(
          details: [
            buildSaleDetail(productName: null, unit: ProductUnitOfMeasure.bag),
          ],
        ),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Producto'), findsOneWidget);
    });
  });
}

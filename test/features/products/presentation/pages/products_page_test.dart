import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/products/domain/repositories/products_repository.dart';
import 'package:arenero/features/products/presentation/pages/products_page.dart';
import 'package:arenero/features/products/presentation/providers/products_providers.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductsPage', () {
    testWidgets('shows active products by default with their status dots', (
      tester,
    ) async {
      final repository = _ProductsRepositoryFake();
      repository.products = [
        _product(id: 'product-1', name: 'Arena fina', active: true),
      ];
      await _pumpPage(tester, repository);

      expect(find.text('Gestión de Productos'), findsOneWidget);
      expect(find.text('Arena fina'), findsOneWidget);
      expect(find.text('Metro cubico · Bs. 50'), findsOneWidget);
      expect(find.byTooltip('Activo'), findsOneWidget);
    });

    testWidgets('does not disable a product when confirmation is cancelled', (
      tester,
    ) async {
      final repository = _ProductsRepositoryFake();
      repository.products = [
        _product(id: 'product-1', name: 'Arena fina', active: true),
      ];
      await _pumpPage(tester, repository);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deshabilitar'));
      await tester.pumpAndSettle();

      expect(find.text('Deshabilitar productos'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCalls, 0);
    });

    testWidgets('disables a selected product after confirmation', (
      tester,
    ) async {
      final repository = _ProductsRepositoryFake();
      repository.products = [
        _product(id: 'product-1', name: 'Arena fina', active: true),
      ];
      await _pumpPage(tester, repository);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deshabilitar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Si, deshabilitar'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCalls, 1);
      expect(repository.lastProductId, 'product-1');
      expect(repository.lastActive, isFalse);
    });

    testWidgets('shows the edit dialog and saves name and price', (
      tester,
    ) async {
      final repository = _ProductsRepositoryFake();
      repository.products = [
        _product(id: 'product-1', name: 'Arena fina', active: true),
      ];
      await _pumpPage(tester, repository);

      await tester.tap(find.byTooltip('Modificar producto'));
      await tester.pumpAndSettle();

      expect(find.text('Modificar producto'), findsOneWidget);

      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.first, 'Arena gruesa');
      await tester.enterText(fields.last, '75.00');
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(repository.lastProductId, 'product-1');
      expect(repository.lastName, 'Arena Gruesa');
      expect(repository.lastUnitId, 'unit-1');
      expect(repository.lastUnitPrice, 75.0);
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  _ProductsRepositoryFake repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: Scaffold(body: ProductsPage())),
    ),
  );
  await tester.pumpAndSettle();
}

Product _product({
  required String id,
  required String name,
  required bool active,
}) {
  return Product(
    id: id,
    name: name,
    active: active,
    units: [
      ProductUnitPrice(
        id: 'unit-1',
        productId: id,
        unit: ProductUnitOfMeasure.m3,
        unitPrice: 50,
        active: true,
      ),
    ],
  );
}

class _ProductsRepositoryFake implements ProductsRepository {
  List<Product> products = [];
  int setActiveCalls = 0;
  String? lastProductId;
  bool? lastActive;
  String? lastName;
  String? lastUnitId;
  double? lastUnitPrice;

  @override
  Future<dartz.Either<Failure, dartz.Unit>> createProduct({
    required String name,
    required ProductUnitOfMeasure unit,
    required double unitPrice,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Either<Failure, List<Product>>> getProducts() async {
    return dartz.Right(products);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> setActive(
    String id,
    bool active,
  ) async {
    setActiveCalls++;
    lastProductId = id;
    lastActive = active;
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateProductName({
    required String id,
    required String name,
  }) async {
    lastProductId = id;
    lastName = name;
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) async {
    lastUnitId = unitId;
    lastUnitPrice = unitPrice;
    return const dartz.Right(dartz.unit);
  }
}

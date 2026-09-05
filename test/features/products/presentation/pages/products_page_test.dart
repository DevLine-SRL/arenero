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
    testWidgets(
      'does not deactivate a product when confirmation is cancelled',
      (tester) async {
        final repository = _ProductsRepositoryFake();
        await _pumpPage(tester, repository);

        await tester.tap(find.byTooltip('Desactivar producto'));
        await tester.pumpAndSettle();

        expect(find.text('Desactivar producto'), findsOneWidget);
        expect(
          find.textContaining(
            'El producto dejará de estar disponible para nuevas ventas.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(repository.setActiveCalls, 0);
      },
    );

    testWidgets('deactivates a product after confirmation', (tester) async {
      final repository = _ProductsRepositoryFake();
      await _pumpPage(tester, repository);

      await tester.tap(find.byTooltip('Desactivar producto'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCalls, 1);
      expect(repository.lastProductId, 'product-1');
      expect(repository.lastActive, isFalse);
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

class _ProductsRepositoryFake implements ProductsRepository {
  int setActiveCalls = 0;
  String? lastProductId;
  bool? lastActive;

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
    return const dartz.Right([
      Product(
        id: 'product-1',
        name: 'Arena fina',
        active: true,
        units: [
          ProductUnitPrice(
            id: 'unit-1',
            productId: 'product-1',
            unit: ProductUnitOfMeasure.m3,
            unitPrice: 50,
            active: true,
          ),
        ],
      ),
    ]);
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
    return const dartz.Right(dartz.unit);
  }

  @override
  Future<dartz.Either<Failure, dartz.Unit>> updateUnitPrice({
    required String unitId,
    required double unitPrice,
  }) async => const dartz.Right(dartz.unit);
}

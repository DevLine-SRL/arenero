import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/sales/data/models/sale_detail_model.dart';
import 'package:arenero/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/sales/domain/entities/sale.dart';
import 'package:arenero/features/sales/domain/entities/sale_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../support/fakes/fake_sales_remote_datasource.dart';

Failure _failureOf(dynamic result) {
  return result.fold(
    (failure) => failure as Failure,
    (_) => fail('expected a Left, got a Right'),
  );
}

void main() {
  late FakeSalesRemoteDataSource dataSource;
  late SalesRepositoryImpl repository;

  setUp(() {
    dataSource = FakeSalesRemoteDataSource();
    repository = SalesRepositoryImpl(dataSource);
  });

  group('getSaleById', () {
    test('forwards the sale id to the data source', () async {
      await repository.getSaleById('sale-42');

      expect(dataSource.lastRequestedSaleId, 'sale-42');
      expect(dataSource.getSaleByIdCallCount, 1);
    });

    test('returns the sale on success', () async {
      final result = await repository.getSaleById('sale-1');

      final sale = result.fold(
        (failure) => fail('expected a Right, got $failure'),
        (sale) => sale,
      );
      expect(sale.number, 12);
      expect(sale.details, hasLength(1));
    });

    test(
      'keeps the price the line was sold at, not the catalog price',
      () async {
        // El producto hoy cuesta 15, pero esta venta se cerró a 10.
        dataSource.saleToReturn = buildSaleModel(
          total: 20,
          details: const [
            SaleDetailModel(
              id: 'detail-1',
              productUnitId: 'product-unit-1',
              unit: ProductUnitOfMeasure.m3,
              quantity: 2,
              unitPrice: 10,
              productName: 'Arena fina',
            ),
          ],
        );

        final result = await repository.getSaleById('sale-1');

        final sale = result.fold(
          (failure) => fail('expected a Right, got $failure'),
          (sale) => sale,
        );
        expect(sale.details.single.unitPrice, 10);
        expect(sale.details.single.subtotal, 20);
      },
    );

    test('maps a missing sale to a NotFoundFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'La venta no existe.',
        code: 'PGRST116',
      );

      final failure = _failureOf(await repository.getSaleById('sale-1'));

      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, 'La venta no existe.');
    });

    test('maps a denied read to an UnauthorizedFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'permission denied',
        code: '42501',
      );

      final failure = _failureOf(await repository.getSaleById('sale-1'));

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, contains('No tienes permisos'));
    });

    test('maps an unknown postgrest code to an UnexpectedFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'boom',
        code: '08006',
      );

      final failure = _failureOf(await repository.getSaleById('sale-1'));

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.code, '08006');
    });

    test('maps a non-postgrest error to an UnexpectedFailure', () async {
      dataSource.errorToThrow = StateError('socket closed');

      final failure = _failureOf(await repository.getSaleById('sale-1'));

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, contains('No se pudo obtener el detalle'));
    });
  });

  group('registerSale', () {
    test('forwards the global discount to the data source', () async {
      await repository.registerSale(
        clientId: 'client-1',
        sellerId: 'seller-1',
        deliveryMode: SaleDeliveryMode.customerPickup,
        paymentMethod: SalePaymentMethod.cash,
        discountAmount: 12,
        freightAmount: 15,
        details: const [
          SaleDetail(
            productUnitId: 'product-unit-1',
            unit: ProductUnitOfMeasure.m3,
            quantity: 2,
            unitPrice: 10,
          ),
        ],
      );

      expect(dataSource.lastRegisteredDiscountAmount, 12);
      expect(dataSource.lastRegisteredFreightAmount, 15);
    });
  });

  group('updateSalePayment', () {
    test(
      'forwards the payment status and amounts to the data source',
      () async {
        final result = await repository.updateSalePayment(
          saleId: 'sale-1',
          paymentStatus: SalePaymentStatus.partial,
          amountPaid: 30,
          pendingAmount: 70,
        );

        result.fold(
          (failure) => fail('expected a Right, got $failure'),
          (_) {},
        );

        expect(dataSource.lastUpdatedPaymentSaleId, 'sale-1');
        expect(dataSource.lastUpdatedPaymentStatus, SalePaymentStatus.partial);
        expect(dataSource.lastUpdatedAmountPaid, 30);
        expect(dataSource.lastUpdatedPendingAmount, 70);
      },
    );

    test('maps an invalid payment to a ValidationFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'El abono parcial debe ser menor al total.',
        code: 'P0001',
      );

      final failure = _failureOf(
        await repository.updateSalePayment(
          saleId: 'sale-1',
          paymentStatus: SalePaymentStatus.partial,
          amountPaid: 100,
          pendingAmount: 0,
        ),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('cobro'));
    });

    test('maps a missing sale to a NotFoundFailure', () async {
      dataSource.errorToThrow = supabase.PostgrestException(
        message: 'La venta indicada no existe.',
        code: 'P0002',
      );

      final failure = _failureOf(
        await repository.updateSalePayment(
          saleId: 'sale-1',
          paymentStatus: SalePaymentStatus.pending,
          amountPaid: 0,
          pendingAmount: 100,
        ),
      );

      expect(failure, isA<NotFoundFailure>());
    });
  });
}

import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/auth/domain/entities/login_lock_status.dart';
import 'package:arenero/features/auth/domain/entities/user.dart';
import 'package:arenero/features/auth/domain/repositories/auth_repository.dart';
import 'package:arenero/features/auth/presentation/providers/auth_providers.dart';
import 'package:arenero/features/products/domain/entities/product.dart';
import 'package:arenero/features/sales/domain/entities/sale.dart';
import 'package:arenero/features/sales/presentation/providers/register_sale_controller_provider.dart';
import 'package:arenero/features/sales/presentation/providers/sales_providers.dart';
import 'package:arenero/features/sellers/domain/entities/seller.dart';
import 'package:arenero/shared/value_objects/value_objects.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/client_builder.dart';
import '../../../../support/builders/sale_builder.dart';
import '../../../../support/fakes/fake_sales_repository.dart';

void main() {
  group('RegisterSaleController', () {
    test('keeps the total at zero when the discount exceeds the subtotal', () {
      final container = _container(
        user: _sellerUser(),
        sales: FakeSalesRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(registerSaleControllerProvider.notifier);
      notifier.addLine();
      notifier.changeLineProduct(0, _product(unitPrice: 20));
      notifier.changeLineQuantity(0, 2);
      notifier.onDiscountAmountChanged(100);

      final state = container.read(registerSaleControllerProvider);
      expect(state.subtotal, 40);
      expect(state.discountAmount, 40);
      expect(state.total, 0);
    });

    test('adds freight only when delivery is domicilio', () {
      final container = _container(
        user: _sellerUser(),
        sales: FakeSalesRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(registerSaleControllerProvider.notifier);
      notifier.addLine();
      notifier.changeLineProduct(0, _product(unitPrice: 20));
      notifier.changeLineQuantity(0, 2);
      notifier.onDiscountAmountChanged(5);

      expect(container.read(registerSaleControllerProvider).total, 35);

      notifier.onDeliveryModeChanged(SaleDeliveryMode.companyDelivery);
      notifier.onFreightAmountChanged(12);

      expect(container.read(registerSaleControllerProvider).total, 47);
    });

    test('registers an admin sale with the selected seller', () async {
      final sales = FakeSalesRepository();
      final container = _container(user: _adminUser(), sales: sales);
      addTearDown(container.dispose);

      final notifier = container.read(registerSaleControllerProvider.notifier);
      notifier.onSellerSelected(
        const Seller(
          id: 'seller-9',
          email: 'laura@arenero.com',
          name: 'Laura',
          active: true,
        ),
      );
      _fillMinimumSale(notifier);

      final failure = await notifier.submit();

      expect(failure, isNull);
      expect(sales.lastRegisteredSellerId, 'seller-9');
      expect(sales.lastRegisteredDiscountAmount, 7);
      expect(sales.lastRegisteredFreightAmount, 0);
    });

    test('registers a seller sale with the current user id', () async {
      final sales = FakeSalesRepository();
      final container = _container(user: _sellerUser(), sales: sales);
      addTearDown(container.dispose);

      final notifier = container.read(registerSaleControllerProvider.notifier);
      _fillMinimumSale(notifier);

      final failure = await notifier.submit();

      expect(failure, isNull);
      expect(sales.lastRegisteredSellerId, 'seller-1');
    });

    test(
      'keeps the registered sale to continue with the payment step',
      () async {
        final sales = FakeSalesRepository();
        sales.registerResult = Right(buildSale(total: 100, pendingAmount: 100));
        final container = _container(user: _sellerUser(), sales: sales);
        addTearDown(container.dispose);

        final notifier = container.read(
          registerSaleControllerProvider.notifier,
        );
        _fillMinimumSale(notifier);

        final failure = await notifier.submit();

        final state = container.read(registerSaleControllerProvider);
        expect(failure, isNull);
        expect(state.registeredSale, isNotNull);
        expect(state.paymentTotal, 100);
        expect(state.paymentStatus, SalePaymentStatus.pending);
      },
    );

    test(
      'records a valid partial payment after registering the sale',
      () async {
        final sales = FakeSalesRepository();
        sales.registerResult = Right(buildSale(total: 100, pendingAmount: 100));
        final container = _container(user: _sellerUser(), sales: sales);
        addTearDown(container.dispose);

        final notifier = container.read(
          registerSaleControllerProvider.notifier,
        );
        _fillMinimumSale(notifier);
        await notifier.submit();

        notifier.onPaymentStatusChanged(SalePaymentStatus.partial);
        notifier.onAmountPaidChanged(40);
        final failure = await notifier.confirmRegisteredSalePayment();

        expect(failure, isNull);
        expect(sales.lastUpdatedPaymentSaleId, 'sale-1');
        expect(sales.lastUpdatedPaymentStatus, SalePaymentStatus.partial);
        expect(sales.lastUpdatedAmountPaid, 40);
        expect(sales.lastUpdatedPendingAmount, 60);
        expect(
          container.read(registerSaleControllerProvider).registeredSale,
          isNull,
        );
      },
    );

    test(
      'rejects a partial payment that is not lower than the total',
      () async {
        final sales = FakeSalesRepository();
        sales.registerResult = Right(buildSale(total: 100, pendingAmount: 100));
        final container = _container(user: _sellerUser(), sales: sales);
        addTearDown(container.dispose);

        final notifier = container.read(
          registerSaleControllerProvider.notifier,
        );
        _fillMinimumSale(notifier);
        await notifier.submit();

        notifier.onPaymentStatusChanged(SalePaymentStatus.partial);
        notifier.onAmountPaidChanged(100);
        final failure = await notifier.confirmRegisteredSalePayment();

        expect(failure, isA<ValidationFailure>());
        expect(sales.lastUpdatedPaymentSaleId, isNull);
        expect(
          container.read(registerSaleControllerProvider).registeredSale,
          isNotNull,
        );
      },
    );
  });
}

ProviderContainer _container({
  required User user,
  required FakeSalesRepository sales,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
      salesRepositoryProvider.overrideWithValue(sales),
    ],
  );
}

void _fillMinimumSale(RegisterSaleController notifier) {
  notifier.onClientSelected(buildClient());
  notifier.addLine();
  notifier.changeLineProduct(0, _product(unitPrice: 20));
  notifier.changeLineQuantity(0, 2);
  notifier.onDiscountAmountChanged(7);
}

Product _product({required double unitPrice}) {
  return Product(
    id: 'product-1',
    name: 'Arena fina',
    active: true,
    units: [
      ProductUnitPrice(
        id: 'product-unit-1',
        productId: 'product-1',
        unit: ProductUnitOfMeasure.m3,
        unitPrice: unitPrice,
        active: true,
      ),
    ],
  );
}

User _adminUser() {
  return const User(
    id: 'admin-1',
    email: 'admin@arenero.com',
    name: 'Admin',
    role: 'admin',
    active: true,
  );
}

User _sellerUser() {
  return const User(
    id: 'seller-1',
    email: 'laura@arenero.com',
    name: 'Laura',
    role: 'seller',
    active: true,
  );
}

class _FakeAuthRepository implements AuthRepository {
  final User user;

  const _FakeAuthRepository(this.user);

  @override
  Future<User?> currentUser() async => user;

  @override
  Stream<User?> watchAuthState() => Stream.value(user);

  @override
  Future<Either<Failure, Unit>> changePassword({required Password password}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoginLockStatus>> getLoginLock() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> login({
    required Email email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, LoginLockStatus>> registerFailedLogin() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> resetLoginAttempts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetCode({required Email email}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DateTime?>> touchLastSeen() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required Email email,
    required String code,
  }) {
    throw UnimplementedError();
  }
}

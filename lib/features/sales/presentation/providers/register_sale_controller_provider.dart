import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../products/domain/entities/product.dart';
import '../../../sellers/domain/entities/seller.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_detail.dart';
import '../../domain/entities/sale_delivery.dart';
import 'register_sale_state.dart';
import 'sales_history_provider.dart';
import 'sales_providers.dart';

part 'register_sale_controller_provider.g.dart';

@riverpod
class RegisterSaleController extends _$RegisterSaleController {
  int _nextRowId = 0;

  @override
  RegisterSaleState build() => const RegisterSaleState();

  void _replaceItem(int rowId, SaleLineItem Function(SaleLineItem) change) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.rowId == rowId) change(item) else item,
      ],
    );
  }

  void onClientSelected(Client client) {
    state = state.copyWith(client: client);
  }

  void onSellerSelected(Seller seller) {
    state = state.copyWith(seller: seller);
  }

  void onClearSeller() {
    state = state.copyWith(clearSeller: true);
  }

  void onClearClient() {
    state = state.copyWith(clearClient: true);
  }

  void onDeliveryModeChanged(SaleDeliveryMode mode) {
    state = state.copyWith(deliveryMode: mode);
  }

  void onVehiclePlateChanged(String value) {
    state = state.copyWith(vehiclePlate: value);
  }

  void onFreightAmountChanged(double value) {
    state = state.copyWith(freightAmount: value < 0 ? 0 : value);
  }

  void onPaymentMethodChanged(SalePaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void onDiscountAmountChanged(double value) {
    state = state.copyWith(discountAmount: value < 0 ? 0 : value);
  }

  void onNotesChanged(String value) {
    state = state.copyWith(notes: value);
  }

  void reset() {
    state = const RegisterSaleState();
    _nextRowId = 0;
  }

  void addLine() {
    state = state.copyWith(
      items: [
        ...state.items,
        SaleLineItem(rowId: _nextRowId++),
      ],
    );
  }

  void changeLineProduct(int rowId, Product product) {
    if (!product.active) return;

    final usedUnits = _unitsInUse(product.id, excludeRowId: rowId);
    final available = [
      for (final entry in product.units)
        if (entry.active && !usedUnits.contains(entry.unit)) entry,
    ];
    final firstUnit = available.isNotEmpty ? available.first : null;

    _replaceItem(
      rowId,
      (item) => item.copyWith(
        productId: product.id,
        productName: product.name,
        unit: firstUnit?.unit,
        productUnitId: firstUnit?.id,
        unitPrice: firstUnit?.unitPrice ?? 0,
        availableUnits: available,
      ),
    );
  }

  Set<ProductUnitOfMeasure> _unitsInUse(String productId, {int? excludeRowId}) {
    final used = <ProductUnitOfMeasure>{};
    for (final item in state.items) {
      if (item.rowId == excludeRowId) continue;
      if (item.isComplete && item.productId == productId && item.unit != null) {
        used.add(item.unit!);
      }
    }
    return used;
  }

  void changeLineUnit(int rowId, ProductUnitOfMeasure unit) {
    _replaceItem(rowId, (item) {
      for (final entry in item.availableUnits) {
        if (entry.unit == unit) {
          return item.copyWith(
            unit: unit,
            productUnitId: entry.id,
            unitPrice: entry.unitPrice,
          );
        }
      }
      return item;
    });
  }

  void changeLineQuantity(int rowId, double quantity) {
    _replaceItem(
      rowId,
      (item) => item.copyWith(quantity: quantity < 1 ? 1 : quantity),
    );
  }

  void changeLineDiscount(int rowId, double discount) {
    _replaceItem(rowId, (item) {
      final maxDiscount = item.quantity * item.unitPrice;
      final clamped = discount < 0
          ? 0.0
          : (discount > maxDiscount ? maxDiscount : discount);
      return item.copyWith(discount: clamped);
    });
  }

  void removeLine(int rowId) {
    state = state.copyWith(
      items: state.items.where((item) => item.rowId != rowId).toList(),
    );
  }

  Future<Failure?> submit() async {
    if (!state.canSubmit) return null;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final user = await ref.read(getCurrentUserUseCaseProvider)();
    if (user == null) {
      const failure = UnauthorizedFailure(
        message: 'No se pudo identificar al vendedor.',
      );
      state = state.copyWith(isSubmitting: false, submitError: failure.message);
      return failure;
    }

    final details = <SaleDetail>[
      for (final item in state.completedItems)
        SaleDetail(
          productUnitId: item.productUnitId!,
          unit: item.unit!,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          discount: item.discount,
        ),
    ];

    final delivery = state.deliveryMode == SaleDeliveryMode.companyDelivery
        ? SaleDelivery(
            vehiclePlate: state.vehiclePlate.trim().isEmpty
                ? null
                : state.vehiclePlate.trim(),
          )
        : null;

    final sellerId = user.role == 'admin' ? state.seller?.id : user.id;
    if (sellerId == null) {
      const failure = ValidationFailure(
        message: 'Selecciona el vendedor de la venta.',
        errors: {'seller': 'Selecciona el vendedor de la venta.'},
      );
      state = state.copyWith(isSubmitting: false, submitError: failure.message);
      return failure;
    }

    final result = await ref.read(registerSaleUseCaseProvider)(
      client: state.client!,
      sellerId: sellerId,
      deliveryMode: state.deliveryMode,
      paymentMethod: state.paymentMethod,
      discountAmount: state.discountAmount,
      freightAmount: state.deliveryMode == SaleDeliveryMode.companyDelivery
          ? state.freightAmount
          : 0,
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      delivery: delivery,
      details: details,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        );
        return failure;
      },
      (_) {
        ref.invalidate(salesHistoryProvider);
        state = const RegisterSaleState();
        return null;
      },
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'mock_sales_data.dart';
import 'register_sale_state.dart';

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

  void onClientSelected(ClientEntry client) {
    state = state.copyWith(client: client);
  }

  void onClearClient() {
    state = state.copyWith(clearClient: true);
  }

  void onDeliveryModeChanged(DeliveryMode mode) {
    state = state.copyWith(deliveryMode: mode);
  }

  void onDeliveryAddressChanged(String value) {
    state = state.copyWith(deliveryAddress: value);
  }

  void onVehiclePlateChanged(String value) {
    state = state.copyWith(vehiclePlate: value);
  }

  void onDeliveryDateChanged(DateTime? date) {
    state = state.copyWith(
      deliveryDate: date,
      clearDeliveryDate: date == null,
    );
  }

  void onPaymentMethodChanged(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void onNotesChanged(String value) {
    state = state.copyWith(notes: value);
  }

  void addLine() {
    state = state.copyWith(
      items: [...state.items, SaleLineItem(rowId: _nextRowId++)],
    );
  }

  void changeLineProduct(int rowId, ProductEntry product) {
    final usedUnits = _unitsInUse(product.id, excludeRowId: rowId);
    final available = [
      for (final entry in product.units)
        if (!usedUnits.contains(entry.unit)) entry,
    ];
    final firstUnit = available.isNotEmpty ? available.first.unit : null;
    final firstPrice = available.isNotEmpty ? available.first.unitPrice : 0.0;

    _replaceItem(
      rowId,
      (item) => item.copyWith(
        productId: product.id,
        productName: product.name,
        unit: firstUnit,
        unitPrice: firstPrice,
        availableUnits: available,
      ),
    );
  }

  Set<UnitOfMeasure> _unitsInUse(String productId, {int? excludeRowId}) {
    final used = <UnitOfMeasure>{};
    for (final item in state.items) {
      if (item.rowId == excludeRowId) continue;
      if (item.isComplete &&
          item.productId == productId &&
          item.unit != null) {
        used.add(item.unit!);
      }
    }
    return used;
  }

  void changeLineUnit(int rowId, UnitOfMeasure unit) {
    _replaceItem(
      rowId,
      (item) {
        final price = lookupPrice(item.availableUnits, unit);
        return item.copyWith(unit: unit, unitPrice: price ?? item.unitPrice);
      },
    );
  }

  void changeLineQuantity(int rowId, double quantity) {
    _replaceItem(
      rowId,
      (item) => item.copyWith(quantity: quantity < 1 ? 1 : quantity),
    );
  }

  void changeLineDiscount(int rowId, double discount) {
    _replaceItem(
      rowId,
      (item) => item.copyWith(discount: discount < 0 ? 0 : discount),
    );
  }

  void removeLine(int rowId) {
    state = state.copyWith(
      items: state.items.where((item) => item.rowId != rowId).toList(),
    );
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    state = state.copyWith(isSubmitting: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = const RegisterSaleState();
  }

  static double? lookupPrice(
    List<ProductUnitEntry> units,
    UnitOfMeasure unit,
  ) {
    for (final entry in units) {
      if (entry.unit == unit) return entry.unitPrice;
    }
    return null;
  }
}
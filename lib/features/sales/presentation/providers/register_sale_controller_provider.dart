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
  RegisterSaleState build() {
    return const RegisterSaleState();
  }

  // ============================================================
  // MÉTODOS INTERNOS
  // ============================================================

  void _replaceItem(int rowId, SaleLineItem Function(SaleLineItem) change) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.rowId == rowId) change(item) else item,
      ],
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  /// Construye los detalles que serán enviados al caso de uso.
  List<SaleDetail> _buildDetails() {
    return [
      for (final item in state.completedItems)
        SaleDetail(
          productUnitId: item.productUnitId!,
          unit: item.unit!,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          discount: item.discount,
        ),
    ];
  }

  /// HU-02:
  /// Solo genera información de delivery cuando
  /// la modalidad es domicilio.
  SaleDelivery? _buildDelivery() {
    if (state.deliveryMode != SaleDeliveryMode.companyDelivery) {
      return null;
    }

    final vehiclePlate = state.vehiclePlate.trim();

    return SaleDelivery(
      vehiclePlate: vehiclePlate.isEmpty ? null : vehiclePlate,
    );
  }

  /// HU-02:
  /// Recoge en planta jamás envía flete.
  double _resolveFreightAmount() {
    if (state.deliveryMode != SaleDeliveryMode.companyDelivery) {
      return 0;
    }

    return state.effectiveFreightAmount;
  }

  /// Valida la información del formulario antes de realizar
  /// cualquier petición.
  Failure? _validateBeforeSubmit() {
    if (state.isSubmitting) {
      return const ValidationFailure(
        message: 'La venta ya se está registrando.',
        errors: {'submit': 'Espera a que termine el registro actual.'},
      );
    }

    if (state.client == null) {
      return const ValidationFailure(
        message: 'Selecciona un cliente.',
        errors: {'client': 'Selecciona un cliente para registrar la venta.'},
      );
    }

    if (state.items.isEmpty) {
      return const ValidationFailure(
        message: 'Agrega al menos un producto.',
        errors: {'products': 'La venta debe contener al menos un producto.'},
      );
    }

    if (state.items.any((item) => !item.isComplete)) {
      return const ValidationFailure(
        message: 'Completa todos los productos de la venta.',
        errors: {'products': 'Existen productos con información incompleta.'},
      );
    }

    if (state.completedItems.isEmpty) {
      return const ValidationFailure(
        message: 'Agrega al menos un producto válido.',
        errors: {'products': 'No existen productos válidos para registrar.'},
      );
    }

    return null;
  }

  // ============================================================
  // CLIENTE Y VENDEDOR
  // ============================================================

  void onClientSelected(Client client) {
    state = state.copyWith(
      client: client,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void onSellerSelected(Seller seller) {
    state = state.copyWith(
      seller: seller,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void onClearSeller() {
    state = state.copyWith(
      clearSeller: true,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void onClearClient() {
    state = state.copyWith(
      clearClient: true,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  // ============================================================
  // HU-02 - ENTREGA Y FLETE
  // ============================================================

  /// Domicilio:
  /// - permite placa
  /// - permite flete
  ///
  /// Recoge en planta:
  /// - elimina placa
  /// - fuerza flete a 0
  void onDeliveryModeChanged(SaleDeliveryMode mode) {
    if (mode == SaleDeliveryMode.customerPickup) {
      state = state.copyWith(
        deliveryMode: mode,
        vehiclePlate: '',
        freightAmount: 0,
        clearSubmitError: true,
        clearRegisteredSale: true,
      );

      return;
    }

    state = state.copyWith(
      deliveryMode: mode,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void onVehiclePlateChanged(String value) {
    if (state.deliveryMode != SaleDeliveryMode.companyDelivery) {
      return;
    }

    state = state.copyWith(
      vehiclePlate: value,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void onFreightAmountChanged(double value) {
    if (state.deliveryMode != SaleDeliveryMode.companyDelivery) {
      state = state.copyWith(
        freightAmount: 0,
        clearSubmitError: true,
        clearRegisteredSale: true,
      );

      return;
    }

    state = state.copyWith(
      freightAmount: value < 0 ? 0 : value,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  // ============================================================
  // MÉTODO DE PAGO
  // ============================================================

  void onPaymentMethodChanged(SalePaymentMethod method) {
    state = state.copyWith(
      paymentMethod: method,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  // ============================================================
  // HU-04 - ESTADO DEL COBRO
  // ============================================================

  void onPaymentStatusChanged(SalePaymentStatus status) {
    final total = state.paymentTotal;

    switch (status) {
      case SalePaymentStatus.paidInFull:
        state = state.copyWith(
          paymentStatus: status,
          amountPaid: total,
          clearSubmitError: true,
        );
        break;

      case SalePaymentStatus.partial:
        final currentAmount = state.amountPaid;

        final validCurrentAmount = currentAmount > 0 && currentAmount < total
            ? currentAmount
            : 0.0;

        state = state.copyWith(
          paymentStatus: status,
          amountPaid: validCurrentAmount,
          clearSubmitError: true,
        );
        break;

      case SalePaymentStatus.pending:
        state = state.copyWith(
          paymentStatus: status,
          amountPaid: 0,
          clearSubmitError: true,
        );
        break;
    }
  }

  /// Registra el monto ingresado para un abono parcial.
  void onAmountPaidChanged(double value) {
    if (state.paymentStatus != SalePaymentStatus.partial) {
      return;
    }

    final total = state.paymentTotal;

    var amount = value;

    if (amount < 0) {
      amount = 0;
    }

    if (amount > total) {
      amount = total;
    }

    state = state.copyWith(amountPaid: amount, clearSubmitError: true);
  }

  // ============================================================
  // DESCUENTO Y NOTAS
  // ============================================================

  void onDiscountAmountChanged(double value) {
    var discount = value;

    if (discount < 0) {
      discount = 0;
    }

    if (discount > state.subtotal) {
      discount = state.subtotal;
    }

    state = state.copyWith(
      discountAmount: discount,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void onNotesChanged(String value) {
    state = state.copyWith(
      notes: value,
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    state = const RegisterSaleState();
    _nextRowId = 0;
  }

  /// Permite eliminar únicamente la referencia de la última
  /// venta registrada una vez terminado el flujo HU-04.
  void clearRegisteredSale() {
    state = state.copyWith(clearRegisteredSale: true);
  }

  void finishPaymentLater() {
    reset();
  }

  // ============================================================
  // PRODUCTOS
  // ============================================================

  void addLine() {
    state = state.copyWith(
      items: [
        ...state.items,
        SaleLineItem(rowId: _nextRowId++),
      ],
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  void changeLineProduct(int rowId, Product product) {
    if (!product.active) {
      return;
    }

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
        clearUnit: firstUnit == null,

        productUnitId: firstUnit?.id,
        clearProductUnitId: firstUnit == null,

        unitPrice: firstUnit?.unitPrice ?? 0,
        availableUnits: available,
      ),
    );
  }

  Set<ProductUnitOfMeasure> _unitsInUse(String productId, {int? excludeRowId}) {
    final used = <ProductUnitOfMeasure>{};

    for (final item in state.items) {
      if (item.rowId == excludeRowId) {
        continue;
      }

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
          : discount > maxDiscount
          ? maxDiscount
          : discount;

      return item.copyWith(discount: clamped);
    });
  }

  void removeLine(int rowId) {
    state = state.copyWith(
      items: state.items.where((item) => item.rowId != rowId).toList(),
      clearSubmitError: true,
      clearRegisteredSale: true,
    );
  }

  // ============================================================
  // REGISTRAR VENTA
  // ============================================================

  Future<Failure?> submit() async {
    // ----------------------------------------------------------
    // 1. Validaciones locales
    // ----------------------------------------------------------

    final validationFailure = _validateBeforeSubmit();

    if (validationFailure != null) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: validationFailure.message,
      );

      return validationFailure;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);

    // ----------------------------------------------------------
    // 2. Obtener usuario autenticado
    // ----------------------------------------------------------

    final user = await ref.read(getCurrentUserUseCaseProvider)();

    if (user == null) {
      const failure = UnauthorizedFailure(
        message: 'No se pudo identificar al vendedor.',
      );

      state = state.copyWith(isSubmitting: false, submitError: failure.message);

      return failure;
    }

    // ----------------------------------------------------------
    // 3. Resolver vendedor
    // ----------------------------------------------------------

    final sellerId = user.role == 'admin' ? state.seller?.id : user.id;

    if (sellerId == null) {
      const failure = ValidationFailure(
        message: 'Selecciona el vendedor de la venta.',
        errors: {'seller': 'Selecciona el vendedor de la venta.'},
      );

      state = state.copyWith(isSubmitting: false, submitError: failure.message);

      return failure;
    }

    // ----------------------------------------------------------
    // 4. Construir información de la venta
    // ----------------------------------------------------------

    final details = _buildDetails();

    final delivery = _buildDelivery();

    final freightAmount = _resolveFreightAmount();

    final notes = state.notes.trim();

    // ----------------------------------------------------------
    // 5. Registrar venta
    // ----------------------------------------------------------

    final result = await ref.read(registerSaleUseCaseProvider)(
      client: state.client!,
      sellerId: sellerId,
      deliveryMode: state.deliveryMode,
      paymentMethod: state.paymentMethod,
      discountAmount: state.effectiveDiscountAmount,

      // HU-02
      freightAmount: freightAmount,

      notes: notes.isEmpty ? null : notes,

      // HU-02
      delivery: delivery,

      details: details,
    );

    // ----------------------------------------------------------
    // 6. Procesar resultado
    // ----------------------------------------------------------

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          submitError: failure.message,
        );

        return failure;
      },
      (sale) {
        ref.invalidate(salesHistoryDataProvider);

        /*
         * HU-04:
         *
         * Limpiamos el formulario pero conservamos la venta
         * registrada.
         *
         * Esto permite que la UI pueda continuar después con:
         *
         * - Cobrado completo
         * - Abono parcial
         * - Pendiente
         *
         * sin perder el id ni el total de la venta.
         */
        state = RegisterSaleState(
          paymentMethod: sale.paymentMethod,
          paymentStatus: sale.paymentStatus,
          amountPaid: sale.amountPaid,
          registeredSale: sale,
        );

        _nextRowId = 0;

        return null;
      },
    );
  }

  Future<Failure?> confirmRegisteredSalePayment() async {
    final sale = state.registeredSale;

    if (sale == null || sale.id == null || sale.id!.trim().isEmpty) {
      const failure = ValidationFailure(
        message: 'No se encontró la venta registrada.',
        errors: {'sale': 'Registra una venta antes de confirmar el cobro.'},
      );

      state = state.copyWith(submitError: failure.message);

      return failure;
    }

    if (!state.hasValidPartialPayment) {
      const failure = ValidationFailure(
        message: 'El abono debe ser mayor a Bs. 0 y menor al total.',
        errors: {'amountPaid': 'Ingresa un abono válido.'},
      );

      state = state.copyWith(submitError: failure.message);

      return failure;
    }

    state = state.copyWith(isRecordingPayment: true, clearSubmitError: true);

    final result = await ref.read(updateSalePaymentUseCaseProvider)(
      saleId: sale.id!.trim(),
      paymentStatus: state.paymentStatus,
      amountPaid: state.effectiveAmountPaid,
      pendingAmount: state.pendingAmount,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRecordingPayment: false,
          submitError: failure.message,
        );

        return failure;
      },
      (_) {
        ref.invalidate(salesHistoryProvider);
        reset();
        return null;
      },
    );
  }
}

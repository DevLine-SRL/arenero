import '../../../clients/domain/entities/client.dart';
import '../../../products/domain/entities/product.dart';
import '../../../sellers/domain/entities/seller.dart';
import '../../domain/entities/sale.dart';

class SaleLineItem {
  final int rowId;

  final String? productId;
  final String? productName;

  final ProductUnitOfMeasure? unit;

  final String? productUnitId;

  final double quantity;
  final double unitPrice;
  final double discount;

  final List<ProductUnitPrice> availableUnits;

  const SaleLineItem({
    required this.rowId,
    this.productId,
    this.productName,
    this.unit,
    this.productUnitId,
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
    this.availableUnits = const [],
  });

  /// Una línea solamente se considera completa cuando posee
  /// toda la información necesaria para registrar el detalle.
  bool get isComplete {
    return productId != null &&
        productUnitId != null &&
        unit != null &&
        quantity > 0 &&
        unitPrice >= 0;
  }

  double get subtotal {
    if (!isComplete) {
      return 0;
    }

    final value = (quantity * unitPrice) - discount;

    return value < 0 ? 0 : value;
  }

  SaleLineItem copyWith({
    String? productId,
    bool clearProduct = false,

    String? productName,
    bool clearProductName = false,

    ProductUnitOfMeasure? unit,
    bool clearUnit = false,

    String? productUnitId,
    bool clearProductUnitId = false,

    double? quantity,
    double? unitPrice,
    double? discount,

    List<ProductUnitPrice>? availableUnits,
  }) {
    return SaleLineItem(
      rowId: rowId,

      productId: clearProduct ? null : (productId ?? this.productId),

      productName: clearProductName ? null : (productName ?? this.productName),

      unit: clearUnit ? null : (unit ?? this.unit),

      productUnitId: clearProductUnitId
          ? null
          : (productUnitId ?? this.productUnitId),

      quantity: quantity ?? this.quantity,

      unitPrice: unitPrice ?? this.unitPrice,

      discount: discount ?? this.discount,

      availableUnits: availableUnits ?? this.availableUnits,
    );
  }
}

class RegisterSaleState {
  final Seller? seller;
  final Client? client;

  // ============================================================
  // HU-02 - ENTREGA
  // ============================================================

  final SaleDeliveryMode deliveryMode;

  final String vehiclePlate;

  final double freightAmount;

  // ============================================================
  // MÉTODO DE PAGO
  // ============================================================

  final SalePaymentMethod paymentMethod;

  // ============================================================
  // HU-04 - COBRO
  // ============================================================

  final SalePaymentStatus paymentStatus;

  /// Monto ingresado o cobrado.
  final double amountPaid;

  /// Venta creada recientemente.
  ///
  /// Permite continuar el flujo de cobro después de registrar
  /// la venta sin perder su ID o su total.
  final Sale? registeredSale;

  // ============================================================
  // OTROS DATOS
  // ============================================================

  final double discountAmount;

  final String notes;

  final List<SaleLineItem> items;

  final bool isSubmitting;

  final bool isRecordingPayment;

  final String? submitError;

  const RegisterSaleState({
    this.seller,
    this.client,

    this.deliveryMode = SaleDeliveryMode.customerPickup,

    this.vehiclePlate = '',

    this.freightAmount = 0,

    this.paymentMethod = SalePaymentMethod.cash,

    this.paymentStatus = SalePaymentStatus.pending,

    this.amountPaid = 0,

    this.registeredSale,

    this.discountAmount = 0,

    this.notes = '',

    this.items = const [],

    this.isSubmitting = false,

    this.isRecordingPayment = false,

    this.submitError,
  });

  // ============================================================
  // PRODUCTOS
  // ============================================================

  List<SaleLineItem> get completedItems {
    return items.where((item) => item.isComplete).toList();
  }

  bool get hasIncompleteItems {
    return items.any((item) => !item.isComplete);
  }

  double get subtotal {
    return items.fold<double>(0, (sum, item) => sum + item.subtotal);
  }

  // ============================================================
  // DESCUENTO
  // ============================================================

  /// Evita que el descuento general sea negativo o superior
  /// al subtotal.
  double get effectiveDiscountAmount {
    if (discountAmount <= 0) {
      return 0;
    }

    if (discountAmount >= subtotal) {
      return subtotal;
    }

    return discountAmount;
  }

  // ============================================================
  // HU-02 - FLETE
  // ============================================================

  /// El flete únicamente afecta la venta cuando la modalidad
  /// es domicilio.
  double get effectiveFreightAmount {
    if (deliveryMode != SaleDeliveryMode.companyDelivery) {
      return 0;
    }

    if (freightAmount <= 0) {
      return 0;
    }

    return freightAmount;
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double get total {
    final value = subtotal - effectiveDiscountAmount + effectiveFreightAmount;

    return value < 0 ? 0 : value;
  }

  // ============================================================
  // HU-04 - TOTAL SOBRE EL QUE SE REALIZA EL COBRO
  // ============================================================

  /// Antes de registrar usa el total calculado del formulario.
  ///
  /// Después de registrar utiliza el total definitivo que
  /// devolvió Supabase.
  double get paymentTotal {
    return registeredSale?.total ?? total;
  }

  /// Dinero efectivamente cobrado según el estado seleccionado.
  double get effectiveAmountPaid {
    switch (paymentStatus) {
      case SalePaymentStatus.paidInFull:
        return paymentTotal;

      case SalePaymentStatus.partial:
        if (amountPaid <= 0) {
          return 0;
        }

        if (amountPaid >= paymentTotal) {
          return paymentTotal;
        }

        return amountPaid;

      case SalePaymentStatus.pending:
        return 0;
    }
  }

  /// Saldo pendiente calculado automáticamente.
  double get pendingAmount {
    final value = paymentTotal - effectiveAmountPaid;

    return value < 0 ? 0 : value;
  }

  /// Indica si la venta todavía tiene dinero por cobrar.
  bool get hasPendingPayment {
    return pendingAmount > 0;
  }

  /// Permite validar específicamente el caso de abono parcial.
  bool get hasValidPartialPayment {
    if (paymentStatus != SalePaymentStatus.partial) {
      return true;
    }

    return amountPaid > 0 && amountPaid < paymentTotal;
  }

  // ============================================================
  // VALIDACIÓN DEL FORMULARIO
  // ============================================================

  bool get canSubmit {
    if (isSubmitting) {
      return false;
    }

    if (client == null) {
      return false;
    }

    if (items.isEmpty) {
      return false;
    }

    if (hasIncompleteItems) {
      return false;
    }

    if (completedItems.isEmpty) {
      return false;
    }

    return true;
  }

  bool get canConfirmPayment {
    if (registeredSale == null || isRecordingPayment) {
      return false;
    }

    return hasValidPartialPayment;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  RegisterSaleState copyWith({
    Seller? seller,
    bool clearSeller = false,

    Client? client,
    bool clearClient = false,

    SaleDeliveryMode? deliveryMode,

    String? vehiclePlate,

    double? freightAmount,

    SalePaymentMethod? paymentMethod,

    SalePaymentStatus? paymentStatus,

    double? amountPaid,

    Sale? registeredSale,
    bool clearRegisteredSale = false,

    double? discountAmount,

    String? notes,

    List<SaleLineItem>? items,

    bool? isSubmitting,

    bool? isRecordingPayment,

    String? submitError,
    bool clearSubmitError = false,
  }) {
    return RegisterSaleState(
      seller: clearSeller ? null : (seller ?? this.seller),

      client: clearClient ? null : (client ?? this.client),

      deliveryMode: deliveryMode ?? this.deliveryMode,

      vehiclePlate: vehiclePlate ?? this.vehiclePlate,

      freightAmount: freightAmount ?? this.freightAmount,

      paymentMethod: paymentMethod ?? this.paymentMethod,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      amountPaid: amountPaid ?? this.amountPaid,

      registeredSale: clearRegisteredSale
          ? null
          : (registeredSale ?? this.registeredSale),

      discountAmount: discountAmount ?? this.discountAmount,

      notes: notes ?? this.notes,

      items: items ?? this.items,

      isSubmitting: isSubmitting ?? this.isSubmitting,

      isRecordingPayment: isRecordingPayment ?? this.isRecordingPayment,

      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}

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

  bool get isComplete => productUnitId != null;

  double get subtotal {
    if (!isComplete) return 0;

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
      productId: clearProduct
          ? null
          : (productId ?? this.productId),
      productName: clearProductName
          ? null
          : (productName ?? this.productName),
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

  final SaleDeliveryMode deliveryMode;
  final String vehiclePlate;
  final double freightAmount;

  final SalePaymentMethod paymentMethod;

  /// HU-04:
  /// Estado del cobro de la venta.
  final SalePaymentStatus paymentStatus;

  /// HU-04:
  /// Monto ingresado cuando existe abono parcial.
  final double amountPaid;

  final double discountAmount;
  final String notes;

  final List<SaleLineItem> items;

  final bool isSubmitting;
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
    this.discountAmount = 0,
    this.notes = '',
    this.items = const [],
    this.isSubmitting = false,
    this.submitError,
  });

  List<SaleLineItem> get completedItems {
    return items.where((item) => item.isComplete).toList();
  }

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  /// HU-02:
  /// El flete solamente afecta la venta si la entrega es domicilio.
  double get effectiveFreightAmount {
    if (deliveryMode != SaleDeliveryMode.companyDelivery) {
      return 0;
    }

    if (freightAmount <= 0) {
      return 0;
    }

    return freightAmount;
  }

  double get total {
    final value =
        subtotal -
        discountAmount +
        effectiveFreightAmount;

    return value < 0 ? 0 : value;
  }

  /// HU-04:
  /// Monto efectivamente cobrado.
  double get effectiveAmountPaid {
    switch (paymentStatus) {
      case SalePaymentStatus.paidInFull:
        return total;

      case SalePaymentStatus.partial:
        if (amountPaid <= 0) {
          return 0;
        }

        if (amountPaid >= total) {
          return total;
        }

        return amountPaid;

      case SalePaymentStatus.pending:
        return 0;
    }
  }

  /// HU-04:
  /// Saldo restante calculado automáticamente.
  double get pendingAmount {
    final value = total - effectiveAmountPaid;

    return value < 0 ? 0 : value;
  }

  /// HU-04:
  /// Indica si todavía existe dinero por cobrar.
  bool get hasPendingPayment {
    return pendingAmount > 0;
  }

  bool get canSubmit {
    return client != null &&
        completedItems.isNotEmpty &&
        !isSubmitting;
  }

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
    double? discountAmount,
    String? notes,
    List<SaleLineItem>? items,
    bool? isSubmitting,
    String? submitError,
  }) {
    return RegisterSaleState(
      seller: clearSeller
          ? null
          : (seller ?? this.seller),
      client: clearClient
          ? null
          : (client ?? this.client),
      deliveryMode:
          deliveryMode ?? this.deliveryMode,
      vehiclePlate:
          vehiclePlate ?? this.vehiclePlate,
      freightAmount:
          freightAmount ?? this.freightAmount,
      paymentMethod:
          paymentMethod ?? this.paymentMethod,
      paymentStatus:
          paymentStatus ?? this.paymentStatus,
      amountPaid:
          amountPaid ?? this.amountPaid,
      discountAmount:
          discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      isSubmitting:
          isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}
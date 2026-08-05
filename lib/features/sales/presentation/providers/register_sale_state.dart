import '../../../clients/domain/entities/client.dart';
import '../../../products/domain/entities/product.dart';
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
    return (quantity * unitPrice) - discount;
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
  final Client? client;
  final SaleDeliveryMode deliveryMode;
  final String deliveryAddress;
  final String vehiclePlate;
  final DateTime? deliveryDate;
  final SalePaymentMethod paymentMethod;
  final String notes;
  final List<SaleLineItem> items;
  final bool isSubmitting;
  final String? submitError;

  const RegisterSaleState({
    this.client,
    this.deliveryMode = SaleDeliveryMode.customerPickup,
    this.deliveryAddress = '',
    this.vehiclePlate = '',
    this.deliveryDate,
    this.paymentMethod = SalePaymentMethod.cash,
    this.notes = '',
    this.items = const [],
    this.isSubmitting = false,
    this.submitError,
  });

  List<SaleLineItem> get completedItems =>
      items.where((item) => item.isComplete).toList();

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  bool get hasDeliveryInfo =>
      deliveryMode == SaleDeliveryMode.companyDelivery &&
      deliveryAddress.trim().isNotEmpty &&
      deliveryDate != null;

  bool get canSubmit =>
      client != null &&
      completedItems.isNotEmpty &&
      (deliveryMode != SaleDeliveryMode.companyDelivery || hasDeliveryInfo) &&
      !isSubmitting;

  RegisterSaleState copyWith({
    Client? client,
    bool clearClient = false,
    SaleDeliveryMode? deliveryMode,
    String? deliveryAddress,
    String? vehiclePlate,
    DateTime? deliveryDate,
    bool clearDeliveryDate = false,
    SalePaymentMethod? paymentMethod,
    String? notes,
    List<SaleLineItem>? items,
    bool? isSubmitting,
    String? submitError,
  }) {
    return RegisterSaleState(
      client: clearClient ? null : (client ?? this.client),
      deliveryMode: deliveryMode ?? this.deliveryMode,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      deliveryDate: clearDeliveryDate
          ? null
          : (deliveryDate ?? this.deliveryDate),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}

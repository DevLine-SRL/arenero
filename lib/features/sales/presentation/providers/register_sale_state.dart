import 'mock_sales_data.dart';

class SaleLineItem {
  final int rowId;
  final String? productId;
  final String? productName;
  final UnitOfMeasure? unit;
  final double quantity;
  final double unitPrice;
  final double discount;
  final List<ProductUnitEntry> availableUnits;

  const SaleLineItem({
    required this.rowId,
    this.productId,
    this.productName,
    this.unit,
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
    this.availableUnits = const [],
  });

  bool get isComplete => productId != null && unit != null;

  double get subtotal {
    if (!isComplete) return 0;
    return (quantity * unitPrice) - discount;
  }

  SaleLineItem copyWith({
    String? productId,
    bool clearProduct = false,
    String? productName,
    bool clearProductName = false,
    UnitOfMeasure? unit,
    bool clearUnit = false,
    double? quantity,
    double? unitPrice,
    double? discount,
    List<ProductUnitEntry>? availableUnits,
  }) {
    return SaleLineItem(
      rowId: rowId,
      productId: clearProduct ? null : (productId ?? this.productId),
      productName: clearProductName
          ? null
          : (productName ?? this.productName),
      unit: clearUnit ? null : (unit ?? this.unit),
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      availableUnits: availableUnits ?? this.availableUnits,
    );
  }
}

class RegisterSaleState {
  final ClientEntry? client;
  final DeliveryMode deliveryMode;
  final String deliveryAddress;
  final String vehiclePlate;
  final DateTime? deliveryDate;
  final PaymentMethod paymentMethod;
  final String notes;
  final List<SaleLineItem> items;
  final bool isSubmitting;

  const RegisterSaleState({
    this.client,
    this.deliveryMode = DeliveryMode.customerPickup,
    this.deliveryAddress = '',
    this.vehiclePlate = '',
    this.deliveryDate,
    this.paymentMethod = PaymentMethod.cash,
    this.notes = '',
    this.items = const [],
    this.isSubmitting = false,
  });

  List<SaleLineItem> get completedItems =>
    items.where((item) => item.isComplete).toList();

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  bool get hasDeliveryInfo =>
    deliveryMode == DeliveryMode.companyDelivery &&
    deliveryAddress.trim().isNotEmpty &&
    deliveryDate != null;

  bool get canSubmit =>
    client != null &&
    completedItems.isNotEmpty &&
    (deliveryMode != DeliveryMode.companyDelivery || hasDeliveryInfo) &&
    !isSubmitting;

  RegisterSaleState copyWith({
    ClientEntry? client,
    bool clearClient = false,
    DeliveryMode? deliveryMode,
    String? deliveryAddress,
    String? vehiclePlate,
    DateTime? deliveryDate,
    bool clearDeliveryDate = false,
    PaymentMethod? paymentMethod,
    String? notes,
    List<SaleLineItem>? items,
    bool? isSubmitting,
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
    );
  }
}

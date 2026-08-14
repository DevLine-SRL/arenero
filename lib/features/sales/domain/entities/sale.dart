import '../../../clients/domain/entities/client.dart';
import 'sale_detail.dart';
import 'sale_delivery.dart';

enum SaleDeliveryMode {
  customerPickup(dbValue: 'customer_pickup', label: 'Recoge en planta'),
  companyDelivery(dbValue: 'company_delivery', label: 'Domicilio');

  final String dbValue;
  final String label;

  const SaleDeliveryMode({required this.dbValue, required this.label});

  static SaleDeliveryMode fromDatabase(String value) {
    return SaleDeliveryMode.values.firstWhere(
      (mode) => mode.dbValue == value,
      orElse: () => SaleDeliveryMode.customerPickup,
    );
  }
}

enum SalePaymentMethod {
  cash(dbValue: 'cash', label: 'Efectivo'),
  transfer(dbValue: 'transfer', label: 'Transferencia'),
  qr(dbValue: 'qr', label: 'QR');

  final String dbValue;
  final String label;

  const SalePaymentMethod({required this.dbValue, required this.label});

  static SalePaymentMethod fromDatabase(String value) {
    return SalePaymentMethod.values.firstWhere(
      (method) => method.dbValue == value,
      orElse: () => SalePaymentMethod.cash,
    );
  }
}

enum SaleStatus {
  registered(dbValue: 'registered', label: 'Registrada'),
  void_(dbValue: 'void', label: 'Anulada');

  final String dbValue;
  final String label;

  const SaleStatus({required this.dbValue, required this.label});

  static SaleStatus fromDatabase(String value) {
    return SaleStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => SaleStatus.registered,
    );
  }
}

class Sale {
  final String? id;
  final int? number;
  final Client client;
  final String sellerId;

  /// Nombre del vendedor. Solo viene en la consulta de detalle.
  final String? sellerName;
  final DateTime saleDate;
  final SaleDeliveryMode deliveryMode;
  final SalePaymentMethod paymentMethod;
  final SaleStatus status;
  final double total;
  final double discountAmount;
  final double freightAmount;
  final String? notes;
  final List<SaleDetail> details;
  final SaleDelivery? delivery;

  const Sale({
    this.id,
    this.number,
    required this.client,
    required this.sellerId,
    this.sellerName,
    required this.saleDate,
    required this.deliveryMode,
    required this.paymentMethod,
    this.status = SaleStatus.registered,
    this.total = 0,
    this.discountAmount = 0,
    this.freightAmount = 0,
    this.notes,
    this.details = const [],
    this.delivery,
  });

  double get computedTotal {
    return details.fold(0, (sum, detail) => sum + detail.subtotal);
  }

  Sale copyWith({
    String? id,
    bool clearId = false,
    int? number,
    Client? client,
    String? sellerId,
    String? sellerName,
    DateTime? saleDate,
    SaleDeliveryMode? deliveryMode,
    SalePaymentMethod? paymentMethod,
    SaleStatus? status,
    double? total,
    double? discountAmount,
    double? freightAmount,
    String? notes,
    bool clearNotes = false,
    List<SaleDetail>? details,
    SaleDelivery? delivery,
    bool clearDelivery = false,
  }) {
    return Sale(
      id: clearId ? null : (id ?? this.id),
      number: number ?? this.number,
      client: client ?? this.client,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      saleDate: saleDate ?? this.saleDate,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      total: total ?? this.total,
      discountAmount: discountAmount ?? this.discountAmount,
      freightAmount: freightAmount ?? this.freightAmount,
      notes: clearNotes ? null : (notes ?? this.notes),
      details: details ?? this.details,
      delivery: clearDelivery ? null : (delivery ?? this.delivery),
    );
  }
}

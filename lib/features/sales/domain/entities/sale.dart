import '../../../clients/domain/entities/client.dart';
import 'sale_detail.dart';
import 'sale_delivery.dart';

enum SaleDeliveryMode {
  customerPickup(dbValue: 'customer_pickup', label: 'Retiro en tienda'),
  companyDelivery(dbValue: 'company_delivery', label: 'Entrega a domicilio');

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
  final Client client;
  final String sellerId;
  final DateTime saleDate;
  final SaleDeliveryMode deliveryMode;
  final SalePaymentMethod paymentMethod;
  final SaleStatus status;
  final double total;
  final String? notes;
  final List<SaleDetail> details;
  final SaleDelivery? delivery;

  const Sale({
    this.id,
    required this.client,
    required this.sellerId,
    required this.saleDate,
    required this.deliveryMode,
    required this.paymentMethod,
    this.status = SaleStatus.registered,
    this.total = 0,
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
    Client? client,
    String? sellerId,
    DateTime? saleDate,
    SaleDeliveryMode? deliveryMode,
    SalePaymentMethod? paymentMethod,
    SaleStatus? status,
    double? total,
    String? notes,
    bool clearNotes = false,
    List<SaleDetail>? details,
    SaleDelivery? delivery,
    bool clearDelivery = false,
  }) {
    return Sale(
      id: clearId ? null : (id ?? this.id),
      client: client ?? this.client,
      sellerId: sellerId ?? this.sellerId,
      saleDate: saleDate ?? this.saleDate,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      total: total ?? this.total,
      notes: clearNotes ? null : (notes ?? this.notes),
      details: details ?? this.details,
      delivery: clearDelivery ? null : (delivery ?? this.delivery),
    );
  }
}

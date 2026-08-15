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

/// HU-04:
///
/// Este enum representa el estado del COBRO,
/// no el método de pago.
enum SalePaymentStatus {
  paidInFull(dbValue: 'paid_in_full', label: 'Cobrado completo'),
  partial(dbValue: 'partial', label: 'Abono parcial'),
  pending(dbValue: 'pending', label: 'Pendiente');

  final String dbValue;
  final String label;

  const SalePaymentStatus({required this.dbValue, required this.label});

  static SalePaymentStatus fromDatabase(String value) {
    return SalePaymentStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => SalePaymentStatus.pending,
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

  /// Nombre del vendedor.
  /// Solo viene en la consulta de detalle.
  final String? sellerName;

  final DateTime saleDate;

  final SaleDeliveryMode deliveryMode;

  /// Efectivo, transferencia o QR.
  final SalePaymentMethod paymentMethod;

  /// HU-04:
  /// Completo, parcial o pendiente.
  final SalePaymentStatus paymentStatus;

  final SaleStatus status;

  final double total;

  final double discountAmount;

  /// HU-02:
  /// Flete de la venta.
  final double freightAmount;

  /// HU-04:
  /// Dinero efectivamente abonado.
  final double amountPaid;

  /// HU-04:
  /// Saldo todavía pendiente.
  final double pendingAmount;

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
    this.paymentStatus = SalePaymentStatus.pending,
    this.status = SaleStatus.registered,
    this.total = 0,
    this.discountAmount = 0,
    this.freightAmount = 0,
    this.amountPaid = 0,
    this.pendingAmount = 0,
    this.notes,
    this.details = const [],
    this.delivery,
  });

  /// Total calculado a partir del detalle.
  ///
  /// HU-02:
  /// El flete solamente se agrega si la venta
  /// corresponde a domicilio.
  double get computedTotal {
    final detailSubtotal = details.fold<double>(
      0,
      (sum, detail) => sum + detail.subtotal,
    );

    final effectiveFreight = deliveryMode == SaleDeliveryMode.companyDelivery
        ? freightAmount
        : 0.0;

    final result = detailSubtotal - discountAmount + effectiveFreight;

    return result < 0 ? 0 : result;
  }

  bool get hasPendingPayment {
    return pendingAmount > 0;
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
    SalePaymentStatus? paymentStatus,
    SaleStatus? status,
    double? total,
    double? discountAmount,
    double? freightAmount,
    double? amountPaid,
    double? pendingAmount,
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
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      total: total ?? this.total,
      discountAmount: discountAmount ?? this.discountAmount,
      freightAmount: freightAmount ?? this.freightAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      notes: clearNotes ? null : (notes ?? this.notes),
      details: details ?? this.details,
      delivery: clearDelivery ? null : (delivery ?? this.delivery),
    );
  }
}

import '../../../clients/data/models/client_model.dart';
import '../../domain/entities/sale.dart';
import 'sale_detail_model.dart';
import 'sale_delivery_model.dart';

class SaleModel extends Sale {
  const SaleModel({
    super.id,
    super.number,
    required super.client,
    required super.sellerId,
    super.sellerName,
    required super.saleDate,
    required super.deliveryMode,
    required super.paymentMethod,
    super.paymentStatus,
    super.status,
    super.total,
    super.discountAmount,
    super.freightAmount,
    super.amountPaid,
    super.pendingAmount,
    super.notes,
    super.details,
    super.delivery,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String?,
      number: json['number'] as int?,
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      sellerId: json['seller_id'] as String,
      sellerName: _sellerNameFromJson(json['seller']),
      saleDate: DateTime.parse(json['sale_date'] as String),
      deliveryMode: SaleDeliveryMode.fromDatabase(
        json['delivery_mode'] as String,
      ),
      paymentMethod: SalePaymentMethod.fromDatabase(
        json['payment_method'] as String,
      ),
      paymentStatus: SalePaymentStatus.fromDatabase(
        json['payment_status'] as String? ?? 'pending',
      ),
      status: SaleStatus.fromDatabase(json['status'] as String),
      total: _toDouble(json['total']),
      discountAmount: _toDouble(json['discount_amount']),
      freightAmount: _toDouble(json['freight_amount']),
      amountPaid: _toDouble(json['amount_paid']),
      pendingAmount: _toDouble(json['pending_amount']),
      notes: json['notes'] as String?,
      details: _detailsFromJson(json['sale_details']),
      delivery: _deliveryFromJson(json['sale_deliveries']),
    );
  }

  /// `profiles.name` es opcional; si falta se usa el correo, que sí es
  /// obligatorio, para no dejar el detalle sin vendedor.
  static String? _sellerNameFromJson(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name'] as String?;
    if (name != null && name.trim().isNotEmpty) return name;
    return raw['email'] as String?;
  }

  static List<SaleDetailModel> _detailsFromJson(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final detail in raw)
        if (detail is Map<String, dynamic>)
          SaleDetailModel.fromJson(detail)
        else if (detail is Map)
          SaleDetailModel.fromJson(Map<String, dynamic>.from(detail)),
    ];
  }

  /// `sale_deliveries.sale_id` es UNIQUE, así que PostgREST trata la relación
  /// como uno a uno y devuelve un objeto en vez de un arreglo. Se aceptan las
  /// dos formas para no depender de cómo infiera la cardinalidad.
  static SaleDeliveryModel? _deliveryFromJson(Object? raw) {
    final source = raw is List ? (raw.isEmpty ? null : raw.first) : raw;
    if (source is Map<String, dynamic>) {
      return SaleDeliveryModel.fromJson(source);
    }
    if (source is Map) {
      return SaleDeliveryModel.fromJson(Map<String, dynamic>.from(source));
    }
    return null;
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0;
  }
}

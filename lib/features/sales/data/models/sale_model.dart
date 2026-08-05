import '../../../clients/data/models/client_model.dart';
import '../../domain/entities/sale.dart';
import 'sale_detail_model.dart';
import 'sale_delivery_model.dart';

class SaleModel extends Sale {
  const SaleModel({
    super.id,
    required super.client,
    required super.sellerId,
    required super.saleDate,
    required super.deliveryMode,
    required super.paymentMethod,
    super.status,
    super.total,
    super.notes,
    super.details,
    super.delivery,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String?,
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      sellerId: json['seller_id'] as String,
      saleDate: DateTime.parse(json['sale_date'] as String),
      deliveryMode: SaleDeliveryMode.fromDatabase(
        json['delivery_mode'] as String,
      ),
      paymentMethod: SalePaymentMethod.fromDatabase(
        json['payment_method'] as String,
      ),
      status: SaleStatus.fromDatabase(json['status'] as String),
      total: _toDouble(json['total']),
      notes: json['notes'] as String?,
      details: _detailsFromJson(json['sale_details']),
      delivery: _deliveryFromJson(json['sale_deliveries']),
    );
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

  static SaleDeliveryModel? _deliveryFromJson(Object? raw) {
    if (raw is! List || raw.isEmpty) return null;
    final first = raw.first;
    if (first is Map<String, dynamic>) {
      return SaleDeliveryModel.fromJson(first);
    }
    if (first is Map) {
      return SaleDeliveryModel.fromJson(Map<String, dynamic>.from(first));
    }
    return null;
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0;
  }
}

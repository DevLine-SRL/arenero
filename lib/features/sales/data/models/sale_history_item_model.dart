import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_history_item.dart';

class SaleHistoryItemModel extends SaleHistoryItem {
  const SaleHistoryItemModel({
    required super.id,
    required super.number,
    required super.clientName,
    required super.clientCi,
    required super.saleDate,
    super.total,
    required super.paymentMethod,
  });

  factory SaleHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return SaleHistoryItemModel(
      id: json['id'] as String,
      number: json['number'] as int?,
      clientName: json['client_name'] as String,
      clientCi: json['client_ci'] as String,
      saleDate: DateTime.parse(json['sale_date'] as String),
      total: _toDouble(json['total']),
      paymentMethod: SalePaymentMethod.fromDatabase(
        json['payment_method'] as String,
      ),
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0;
  }
}

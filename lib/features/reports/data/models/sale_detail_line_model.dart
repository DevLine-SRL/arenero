import '../../domain/entities/sale_detail_line.dart';
import 'json_parsing.dart';

class SaleDetailLineModel extends SaleDetailLine {
  const SaleDetailLineModel({
    required super.saleId,
    required super.number,
    required super.saleDate,
    required super.productName,
    required super.unit,
    required super.quantity,
    required super.subtotal,
  });

  factory SaleDetailLineModel.fromJson(Map<String, dynamic> json) {
    return SaleDetailLineModel(
      saleId: jsonString(json['sale_id']),
      number: jsonString(json['number']),
      saleDate: DateTime.parse(json['sale_date'] as String),
      productName: jsonString(json['product_name']),
      unit: jsonString(json['unit']),
      quantity: jsonDouble(json['quantity']),
      subtotal: jsonDouble(json['subtotal']),
    );
  }
}

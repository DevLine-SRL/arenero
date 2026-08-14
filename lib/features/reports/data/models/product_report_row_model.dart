import '../../domain/entities/product_report_row.dart';
import 'json_parsing.dart';

class ProductReportRowModel extends ProductReportRow {
  const ProductReportRowModel({
    required super.productUnitId,
    required super.productName,
    required super.unit,
    required super.qtySold,
    required super.totalAmount,
  });

  factory ProductReportRowModel.fromJson(Map<String, dynamic> json) {
    return ProductReportRowModel(
      productUnitId: jsonString(json['product_unit_id']),
      productName: jsonString(json['product_name']),
      unit: jsonString(json['unit']),
      qtySold: jsonDouble(json['qty_sold']),
      totalAmount: jsonDouble(json['total_amount']),
    );
  }
}

import '../../domain/entities/seller_report_row.dart';
import 'json_parsing.dart';

class SellerReportRowModel extends SellerReportRow {
  const SellerReportRowModel({
    required super.sellerId,
    required super.sellerName,
    required super.nSales,
    required super.totalSold,
  });

  factory SellerReportRowModel.fromJson(Map<String, dynamic> json) {
    return SellerReportRowModel(
      sellerId: jsonString(json['seller_id']),
      sellerName: jsonString(json['seller_name']),
      nSales: jsonInt(json['n_sales']),
      totalSold: jsonDouble(json['total_sold']),
    );
  }
}

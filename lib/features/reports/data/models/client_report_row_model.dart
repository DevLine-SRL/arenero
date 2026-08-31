import '../../domain/entities/client_report_row.dart';
import 'json_parsing.dart';

class ClientReportRowModel extends ClientReportRow {
  const ClientReportRowModel({
    required super.clientId,
    required super.clientName,
    required super.nSales,
    required super.total,
  });

  factory ClientReportRowModel.fromJson(Map<String, dynamic> json) {
    return ClientReportRowModel(
      clientId: jsonString(json['client_id']),
      clientName: jsonString(json['client_name']),
      nSales: jsonInt(json['n_sales']),
      total: jsonDouble(json['total']),
    );
  }
}

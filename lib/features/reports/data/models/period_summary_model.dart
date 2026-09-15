import '../../domain/entities/period_summary.dart';
import 'json_parsing.dart';

class PeriodSummaryModel extends PeriodSummary {
  const PeriodSummaryModel({
    required super.nSales,
    required super.totalSold,
    required super.avgTicket,
  });

  factory PeriodSummaryModel.fromJson(Map<String, dynamic> json) {
    return PeriodSummaryModel(
      nSales: jsonInt(json['n_sales']),
      totalSold: jsonDouble(json['total_sold']),
      avgTicket: jsonDouble(json['avg_ticket']),
    );
  }
}

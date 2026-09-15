import 'package:arenero/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:arenero/features/reports/data/models/client_report_row_model.dart';
import 'package:arenero/features/reports/data/models/period_summary_model.dart';
import 'package:arenero/features/reports/data/models/product_report_row_model.dart';
import 'package:arenero/features/reports/data/models/report_suggestion_model.dart';
import 'package:arenero/features/reports/data/models/sale_detail_line_model.dart';
import 'package:arenero/features/reports/data/models/seller_report_row_model.dart';

class FakeReportsRemoteDataSource implements ReportsRemoteDataSource {
  PeriodSummaryModel? periodSummaryToReturn;
  Object? errorToThrow;

  @override
  Future<PeriodSummaryModel> getPeriodSummary({
    required DateTime start,
    required DateTime end,
  }) async {
    _maybeThrow();
    return periodSummaryToReturn ??
        const PeriodSummaryModel(nSales: 1, totalSold: 100, avgTicket: 100);
  }

  @override
  Future<List<ClientReportRowModel>> getReportByClient({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    _maybeThrow();
    return const [];
  }

  @override
  Future<List<SellerReportRowModel>> getReportBySeller({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    _maybeThrow();
    return const [];
  }

  @override
  Future<List<ProductReportRowModel>> getReportByProduct({
    required DateTime start,
    required DateTime end,
  }) async {
    _maybeThrow();
    return const [];
  }

  @override
  Future<List<ReportSuggestionModel>> searchClients(String query) async {
    _maybeThrow();
    return const [];
  }

  @override
  Future<List<ReportSuggestionModel>> searchSellers(String query) async {
    _maybeThrow();
    return const [];
  }

  @override
  Future<({List<SaleDetailLineModel> items, int totalCount})> getSaleDetails({
    required DateTime start,
    required DateTime end,
    String? clientId,
    String? sellerId,
    String search = '',
    String orderColumn = 'sale_date',
    bool ascending = false,
    required int page,
    int pageSize = 8,
  }) async {
    _maybeThrow();
    return (items: const <SaleDetailLineModel>[], totalCount: 0);
  }

  void _maybeThrow() {
    final error = errorToThrow;
    if (error != null) throw error;
  }
}

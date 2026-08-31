import 'package:arenero/core/errors/failures.dart';
import 'package:arenero/features/reports/domain/entities/client_report_row.dart';
import 'package:arenero/features/reports/domain/entities/period_summary.dart';
import 'package:arenero/features/reports/domain/entities/product_report_row.dart';
import 'package:arenero/features/reports/domain/entities/report_suggestion.dart';
import 'package:arenero/features/reports/domain/entities/sale_details_page.dart';
import 'package:arenero/features/reports/domain/entities/seller_report_row.dart';
import 'package:arenero/features/reports/domain/repositories/reports_repository.dart';
import 'package:dartz/dartz.dart';

import '../builders/report_builders.dart';

class FakeReportsRepository implements ReportsRepository {
  Either<Failure, PeriodSummary>? periodSummaryResult;
  Either<Failure, List<ClientReportRow>>? reportByClientResult;
  Either<Failure, List<SellerReportRow>>? reportBySellerResult;
  Either<Failure, List<ProductReportRow>>? reportByProductResult;
  Either<Failure, List<ReportSuggestion>>? searchClientsResult;
  Either<Failure, List<ReportSuggestion>>? searchSellersResult;
  Either<Failure, SaleDetailsPage>? saleDetailsResult;

  int saleDetailsCallCount = 0;
  String? lastSearchClientsQuery;
  String? lastSearchSellersQuery;
  ({DateTime start, DateTime end})? lastPeriodSummaryRange;
  ({
    DateTime start,
    DateTime end,
    String? clientId,
    String? sellerId,
    int page,
    int pageSize,
  })?
  lastSaleDetailsArgs;
  ({DateTime start, DateTime end, int? limit})? lastReportByClientArgs;
  ({DateTime start, DateTime end, int? limit})? lastReportBySellerArgs;

  @override
  Future<Either<Failure, PeriodSummary>> getPeriodSummary({
    required DateTime start,
    required DateTime end,
  }) async {
    lastPeriodSummaryRange = (start: start, end: end);
    return periodSummaryResult ?? Right(buildPeriodSummary());
  }

  @override
  Future<Either<Failure, List<ClientReportRow>>> getReportByClient({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    lastReportByClientArgs = (start: start, end: end, limit: limit);
    return reportByClientResult ?? Right([buildClientReportRow()]);
  }

  @override
  Future<Either<Failure, List<SellerReportRow>>> getReportBySeller({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    lastReportBySellerArgs = (start: start, end: end, limit: limit);
    return reportBySellerResult ?? Right([buildSellerReportRow()]);
  }

  @override
  Future<Either<Failure, List<ProductReportRow>>> getReportByProduct({
    required DateTime start,
    required DateTime end,
  }) async {
    return reportByProductResult ?? Right([buildProductReportRow()]);
  }

  @override
  Future<Either<Failure, List<ReportSuggestion>>> searchClients(
    String query,
  ) async {
    lastSearchClientsQuery = query;
    return searchClientsResult ?? Right([buildReportSuggestion()]);
  }

  @override
  Future<Either<Failure, List<ReportSuggestion>>> searchSellers(
    String query,
  ) async {
    lastSearchSellersQuery = query;
    return searchSellersResult ?? Right([buildReportSuggestion()]);
  }

  @override
  Future<Either<Failure, SaleDetailsPage>> getSaleDetails({
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
    saleDetailsCallCount++;
    lastSaleDetailsArgs = (
      start: start,
      end: end,
      clientId: clientId,
      sellerId: sellerId,
      page: page,
      pageSize: pageSize,
    );
    return saleDetailsResult ?? Right(buildSaleDetailsPage());
  }
}

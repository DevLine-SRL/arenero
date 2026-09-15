import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_report_row.dart';
import '../entities/period_summary.dart';
import '../entities/product_report_row.dart';
import '../entities/report_suggestion.dart';
import '../entities/sale_details_page.dart';
import '../entities/seller_report_row.dart';

abstract class ReportsRepository {
  Future<Either<Failure, PeriodSummary>> getPeriodSummary({
    required DateTime start,
    required DateTime end,
  });

  Future<Either<Failure, List<ClientReportRow>>> getReportByClient({
    required DateTime start,
    required DateTime end,
    int? limit,
  });

  Future<Either<Failure, List<SellerReportRow>>> getReportBySeller({
    required DateTime start,
    required DateTime end,
    int? limit,
  });

  Future<Either<Failure, List<ProductReportRow>>> getReportByProduct({
    required DateTime start,
    required DateTime end,
  });

  Future<Either<Failure, List<ReportSuggestion>>> searchClients(String query);

  Future<Either<Failure, List<ReportSuggestion>>> searchSellers(String query);

  Future<Either<Failure, SaleDetailsPage>> getSaleDetails({
    required DateTime start,
    required DateTime end,
    String? clientId,
    String? sellerId,
    String search,
    String orderColumn,
    bool ascending,
    required int page,
    int pageSize,
  });
}

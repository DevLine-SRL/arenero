import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../reports/domain/entities/client_report_row.dart';
import '../../../reports/domain/entities/period_summary.dart';
import '../../../reports/domain/entities/seller_report_row.dart';
import 'reports_date_range_provider.dart';
import 'reports_providers.dart';

part 'reports_summary_provider.g.dart';

class ReportsSummaryData {
  final PeriodSummary period;
  final List<ClientReportRow> topClients;
  final List<SellerReportRow> topSellers;

  const ReportsSummaryData({
    required this.period,
    required this.topClients,
    required this.topSellers,
  });
}

@riverpod
Future<ReportsSummaryData> reportsSummary(Ref ref) async {
  final range = ref.watch(reportsDateRangeProvider);

  final periodFuture = ref.watch(getPeriodSummaryUseCaseProvider)(
    start: range.startDate,
    end: range.endDate,
  );
  final clientsFuture = ref.watch(getReportByClientUseCaseProvider)(
    start: range.startDate,
    end: range.endDate,
    limit: 3,
  );
  final sellersFuture = ref.watch(getReportBySellerUseCaseProvider)(
    start: range.startDate,
    end: range.endDate,
    limit: 3,
  );

  final period = (await periodFuture).fold(
    (failure) => throw failure,
    (value) => value,
  );
  final topClients = (await clientsFuture).fold(
    (failure) => throw failure,
    (value) => value,
  );
  final topSellers = (await sellersFuture).fold(
    (failure) => throw failure,
    (value) => value,
  );

  return ReportsSummaryData(
    period: period,
    topClients: topClients,
    topSellers: topSellers,
  );
}

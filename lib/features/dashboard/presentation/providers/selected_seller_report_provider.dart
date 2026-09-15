import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../reports/domain/entities/seller_report_row.dart';
import 'reports_date_range_provider.dart';
import 'reports_providers.dart';

part 'selected_seller_report_provider.g.dart';

@riverpod
Future<SellerReportRow?> selectedSellerReport(Ref ref, String? sellerId) async {
  if (sellerId == null || sellerId.isEmpty) return null;

  final range = ref.watch(reportsDateRangeProvider);
  final useCase = ref.watch(getReportBySellerUseCaseProvider);

  final result = await useCase(start: range.startDate, end: range.endDate);
  final rows = result.fold((failure) => throw failure, (rows) => rows);

  for (final row in rows) {
    if (row.sellerId == sellerId) return row;
  }
  return null;
}

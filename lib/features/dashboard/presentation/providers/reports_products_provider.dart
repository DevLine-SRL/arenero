import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../reports/domain/entities/product_report_row.dart';
import 'reports_date_range_provider.dart';
import 'reports_providers.dart';

part 'reports_products_provider.g.dart';

@riverpod
Future<List<ProductReportRow>> reportsProducts(Ref ref) async {
  final range = ref.watch(reportsDateRangeProvider);
  final useCase = ref.watch(getReportByProductUseCaseProvider);

  final result = await useCase(start: range.startDate, end: range.endDate);
  return result.fold((failure) => throw failure, (rows) => rows);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../reports/domain/entities/client_report_row.dart';
import 'reports_date_range_provider.dart';
import 'reports_providers.dart';

part 'selected_client_report_provider.g.dart';

@riverpod
Future<ClientReportRow?> selectedClientReport(Ref ref, String? clientId) async {
  if (clientId == null || clientId.isEmpty) return null;

  final range = ref.watch(reportsDateRangeProvider);
  final useCase = ref.watch(getReportByClientUseCaseProvider);

  final result = await useCase(start: range.startDate, end: range.endDate);
  final rows = result.fold((failure) => throw failure, (rows) => rows);

  for (final row in rows) {
    if (row.clientId == clientId) return row;
  }
  return null;
}

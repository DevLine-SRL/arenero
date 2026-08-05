import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale.dart';
import '../utils/sale_formatters.dart';
import 'sales_history_date_range_provider.dart';
import 'sales_history_mock_provider.dart';
import 'sales_history_search_query_provider.dart';

part 'sales_history_provider.g.dart';

@riverpod
List<Sale> salesHistory(Ref ref) {
  final query = ref.watch(salesHistorySearchQueryProvider);
  final range = ref.watch(salesHistoryDateRangeProvider);
  final sales = ref.watch(salesHistoryMockDataProvider);

  return sales.where((sale) {
    if (!range.includes(sale.saleDate)) return false;

    final needle = normalizeSearchText(query.trim());
    if (needle.isEmpty) return true;

    final client = normalizeSearchText(sale.client.name);
    final ci = normalizeSearchText(sale.client.ci);
    final nit = normalizeSearchText(sale.client.nit ?? '');
    return client.contains(needle) ||
        ci.contains(needle) ||
        nit.contains(needle);
  }).toList();
}

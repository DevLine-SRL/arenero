import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale_history_item.dart';
import '../utils/sale_formatters.dart';
import 'sales_history_date_range_provider.dart';
import 'sales_history_search_query_provider.dart';
import 'sales_providers.dart';

part 'sales_history_provider.g.dart';

@riverpod
Future<List<SaleHistoryItem>> salesHistory(Ref ref) async {
  final query = ref.watch(salesHistorySearchQueryProvider);
  final range = ref.watch(salesHistoryDateRangeProvider);
  final useCase = ref.watch(getSalesHistoryUseCaseProvider);

  final result = await useCase(from: range.startDate, to: range.endDate);
  final items = result.fold((failure) => throw failure, (items) => items);

  final needle = normalizeSearchText(query.trim());
  if (needle.isEmpty) return items;

  return items.where((item) {
    final client = normalizeSearchText(item.clientName);
    final ci = normalizeSearchText(item.clientCi);
    return client.contains(needle) || ci.contains(needle);
  }).toList();
}

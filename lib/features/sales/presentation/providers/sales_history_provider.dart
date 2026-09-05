import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sale_history_item.dart';
import '../utils/sale_formatters.dart';
import 'sales_history_date_range_provider.dart';
import 'sales_history_search_query_provider.dart';
import 'sales_history_sort_provider.dart';
import 'sales_providers.dart';

part 'sales_history_provider.g.dart';

@riverpod
Future<List<SaleHistoryItem>> salesHistoryData(Ref ref) async {
  final range = ref.watch(salesHistoryDateRangeProvider);
  final useCase = ref.watch(getSalesHistoryUseCaseProvider);

  final result = await useCase(from: range.startDate, to: range.endDate);
  return result.fold((failure) => throw failure, (items) => items);
}

@riverpod
List<SaleHistoryItem> salesHistory(Ref ref) {
  final items =
      ref.watch(salesHistoryDataProvider).value ?? const <SaleHistoryItem>[];
  final query = ref.watch(salesHistorySearchQueryProvider);
  final sort = ref.watch(salesHistorySortProvider);

  final needle = normalizeSearchText(query.trim());
  List<SaleHistoryItem> result = items;
  if (needle.isNotEmpty) {
    result = items.where((item) {
      final client = normalizeSearchText(item.clientName);
      final ci = normalizeSearchText(item.clientCi);
      return client.contains(needle) || ci.contains(needle);
    }).toList();
  }

  final option = sort;
  if (option != null) {
    result = [...result]
      ..sort((a, b) {
        final comparison = switch (option.field) {
          SalesHistorySortField.number => a.number.compareTo(b.number),
          SalesHistorySortField.client => normalizeSearchText(
            a.clientName,
          ).compareTo(normalizeSearchText(b.clientName)),
          SalesHistorySortField.total => a.total.compareTo(b.total),
        };
        return option.direction == SalesHistorySortDirection.ascending
            ? comparison
            : -comparison;
      });
  }

  return result;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/is_online_provider.dart';
import '../../domain/entities/sale_history_item.dart';
import '../utils/sale_formatters.dart';
import 'sales_history_date_range_provider.dart';
import 'sales_history_search_query_provider.dart';
import 'sales_providers.dart';

part 'sales_history_provider.g.dart';

@riverpod
class SalesHistory extends _$SalesHistory {
  bool _refreshInFlight = false;
  DateRangeFilter? _refreshedRange;

  @override
  Future<List<SaleHistoryItem>> build() async {
    final query = ref.watch(salesHistorySearchQueryProvider);
    final range = ref.watch(salesHistoryDateRangeProvider);
    ref.watch(getSalesHistoryUseCaseProvider);
    ref.watch(getCachedSalesHistoryUseCaseProvider);

    final cachedResult = await ref.read(getCachedSalesHistoryUseCaseProvider)(
      from: range.startDate,
      to: range.endDate,
    );
    final cached = cachedResult.fold((_) => null, (items) => items);
    if (cached != null) {
      _refreshInBackground(range);
      return _applyFilter(cached, query);
    }

    final remote = await ref.read(getSalesHistoryUseCaseProvider)(
      from: range.startDate,
      to: range.endDate,
    );
    final items = remote.fold((failure) => throw failure, (items) => items);
    return _applyFilter(items, query);
  }

  Future<void> _refreshInBackground(DateRangeFilter range) async {
    if (_refreshInFlight) return;
    if (_refreshedRange == range) return;
    if (!ref.read(isOnlineProvider)) return;
    _refreshInFlight = true;
    try {
      final result = await ref.read(getSalesHistoryUseCaseProvider)(
        from: range.startDate,
        to: range.endDate,
      );
      if (!ref.mounted) return;
      result.fold((_) {}, (items) {
        _refreshedRange = range;
        final query = ref.read(salesHistorySearchQueryProvider);
        state = AsyncData(_applyFilter(items, query));
      });
    } finally {
      _refreshInFlight = false;
    }
  }

  List<SaleHistoryItem> _applyFilter(
    List<SaleHistoryItem> items,
    String query,
  ) {
    final needle = normalizeSearchText(query.trim());
    if (needle.isEmpty) return items;
    return items.where((item) {
      final client = normalizeSearchText(item.clientName);
      final ci = normalizeSearchText(item.clientCi);
      return client.contains(needle) || ci.contains(needle);
    }).toList();
  }
}

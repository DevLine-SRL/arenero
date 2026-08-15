import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/datasources/sync_local_datasource.dart';
import '../../../../core/providers/is_online_provider.dart';
import '../../../../core/providers/sync_local_datasource_provider.dart';
import '../../domain/entities/sale.dart';
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
      final merged = await _mergeWithPending(cached);
      return _applyFilter(merged, query);
    }

    final remote = await ref.read(getSalesHistoryUseCaseProvider)(
      from: range.startDate,
      to: range.endDate,
    );
    final items = remote.fold((failure) => throw failure, (items) => items);
    final merged = await _mergeWithPending(items);
    return _applyFilter(merged, query);
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
      result.fold((_) {}, (items) async {
        _refreshedRange = range;
        final merged = await _mergeWithPending(items);
        if (!ref.mounted) return;
        final query = ref.read(salesHistorySearchQueryProvider);
        state = AsyncData(_applyFilter(merged, query));
      });
    } finally {
      _refreshInFlight = false;
    }
  }

  Future<List<SaleHistoryItem>> _mergeWithPending(
    List<SaleHistoryItem> items,
  ) async {
    final pending = await ref
        .read(syncLocalDataSourceProvider)
        .getPendingOperations();
    final pendingItems = <SaleHistoryItem>[
      for (final operation in pending)
        if (operation.operation == OutboxOperationType.registerSale)
          _pendingHistoryItem(operation),
    ];
    if (pendingItems.isEmpty) return items;

    final mergedIds = {for (final item in pendingItems) item.id};
    return [
      ...pendingItems,
      for (final item in items)
        if (!mergedIds.contains(item.id)) item,
    ];
  }

  SaleHistoryItem _pendingHistoryItem(PendingOperation operation) {
    final payload = operation.payload;
    return SaleHistoryItem(
      id: payload['id'] as String,
      number: null,
      clientName: payload['client_name'] as String? ?? '',
      clientCi: payload['client_ci'] as String? ?? '',
      saleDate: DateTime.parse(payload['sale_date'] as String),
      total: (payload['total'] as num).toDouble(),
      paymentMethod: SalePaymentMethod.fromDatabase(
        payload['payment_method'] as String,
      ),
    );
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

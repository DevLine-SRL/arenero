import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_history_date_range_provider.dart';
import '../providers/sales_history_provider.dart';
import '../providers/sales_history_search_query_provider.dart';
import '../widgets/sales_history_date_filter.dart';
import '../widgets/sales_history_empty_state.dart';
import '../widgets/sales_history_list_header.dart';
import '../widgets/sales_history_list_item.dart';
import '../widgets/sales_history_search_field.dart';

class SalesHistoryPage extends ConsumerWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesHistoryProvider);
    final query = ref.watch(salesHistorySearchQueryProvider);
    final range = ref.watch(salesHistoryDateRangeProvider);

    final hasFilters = query.trim().isNotEmpty || range.isActive;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SalesHistorySearchField(),
            const SizedBox(height: 8),
            const SalesHistoryDateFilter(),
            const SizedBox(height: 12),
            Expanded(
              child: sales.isEmpty
                  ? SalesHistoryEmptyState(
                      message: hasFilters
                          ? 'Ninguna venta coincide con los filtros'
                          : 'Aún no hay ventas registradas',
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: SalesHistoryListItem.contentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SalesHistoryListHeader(),
                            const SizedBox(height: 4),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: sales.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) =>
                                    SalesHistoryListItem(sale: sales[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

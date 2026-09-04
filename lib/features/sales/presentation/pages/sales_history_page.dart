import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/widgets/page_header.dart';
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
    final salesAsync = ref.watch(salesHistoryProvider);
    final query = ref.watch(salesHistorySearchQueryProvider);
    final range = ref.watch(salesHistoryDateRangeProvider);

    final hasFilters = query.trim().isNotEmpty || range.isActive;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Historial de Ventas',
              description: 'Consulta y seguimiento de ventas realizadas',
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(height: 16),
            const SalesHistorySearchField(),
            const SizedBox(height: 8),
            const SalesHistoryDateFilter(),
            const SizedBox(height: 12),
            Expanded(
              child: salesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(
                  message: error is Failure
                      ? error.message
                      : 'Error inesperado al cargar el historial.',
                  onRetry: () => ref.invalidate(salesHistoryProvider),
                ),
                data: (sales) {
                  if (sales.isEmpty) {
                    return SalesHistoryEmptyState(
                      message: hasFilters
                          ? 'Ninguna venta coincide con los filtros'
                          : 'Aún no hay ventas registradas',
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final effectiveWidth =
                          availableWidth < SalesHistoryListItem.minContentWidth
                          ? SalesHistoryListItem.minContentWidth
                          : availableWidth;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: effectiveWidth,
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

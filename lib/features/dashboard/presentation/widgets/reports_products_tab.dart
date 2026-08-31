import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../reports/domain/entities/product_report_row.dart';
import '../providers/reports_products_provider.dart';
import '../utils/report_formatters.dart';
import 'reports_empty_state.dart';
import 'reports_error_state.dart';

class ReportsProductsTab extends ConsumerWidget {
  const ReportsProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(reportsProductsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ReportsErrorState(
          message: error is Failure
              ? error.message
              : 'Error inesperado al cargar los productos.',
          onRetry: () => ref.invalidate(reportsProductsProvider),
        ),
        data: (rows) {
          final sorted = [...rows]
            ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
          if (sorted.isEmpty) {
            return const ReportsEmptyState(
              message:
                  'No se encontraron ventas para los filtros seleccionados',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < sorted.length; index++) ...[
                  _ProductReportCard(row: sorted[index]),
                  if (index != sorted.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductReportCard extends StatelessWidget {
  final ProductReportRow row;

  const _ProductReportCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              row.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Unidad: ${formatReportUnit(row.unit)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cantidad: ${formatReportQuantity(row.qtySold)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  formatReportAmount(row.totalAmount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

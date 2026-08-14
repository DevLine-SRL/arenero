import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../providers/reports_summary_provider.dart';
import '../utils/report_formatters.dart';
import 'report_kpi_card.dart';
import 'reports_error_state.dart';
import 'stack_or_row.dart';

class ReportsSummaryTab extends ConsumerWidget {
  const ReportsSummaryTab({super.key});

  void _goToTab(BuildContext context, int index) {
    DefaultTabController.of(context).animateTo(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportsSummaryProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ReportsErrorState(
          message: error is Failure
              ? error.message
              : 'Error inesperado al cargar el resumen.',
          onRetry: () => ref.invalidate(reportsSummaryProvider),
        ),
        data: (summary) {
          final topClients = [
            for (final row in summary.topClients)
              _TopEntry(
                name: row.clientName,
                amount: formatReportAmount(row.total),
              ),
          ];
          final topSellers = [
            for (final row in summary.topSellers)
              _TopEntry(
                name: row.sellerName,
                amount: formatReportAmount(row.totalSold),
              ),
          ];

          final kpis = [
            ReportKpiCard(
              title: 'Total vendido',
              value: formatReportAmount(summary.period.totalSold),
              icon: Icons.payments_outlined,
            ),
            ReportKpiCard(
              title: 'N° de ventas',
              value: '${summary.period.nSales}',
              icon: Icons.receipt_long_outlined,
            ),
            ReportKpiCard(
              title: 'Ticket promedio',
              value: formatReportAmount(summary.period.avgTicket),
              icon: Icons.trending_up_rounded,
            ),
          ];
          final topLists = [
            _TopRankedList(
              title: 'Top clientes',
              entries: topClients,
              onSeeAll: () => _goToTab(context, 1),
            ),
            _TopRankedList(
              title: 'Top vendedores',
              entries: topSellers,
              onSeeAll: () => _goToTab(context, 2),
            ),
          ];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StackOrRow(children: kpis),
                const SizedBox(height: 16),
                StackOrRow(children: topLists),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopEntry {
  final String name;
  final String amount;

  const _TopEntry({required this.name, required this.amount});
}

class _TopRankedList extends StatelessWidget {
  final String title;
  final List<_TopEntry> entries;
  final VoidCallback onSeeAll;

  const _TopRankedList({
    required this.title,
    required this.entries,
    required this.onSeeAll,
  });

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('Ver todos →'),
                ),
              ],
            ),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sin datos en el período',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.amount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

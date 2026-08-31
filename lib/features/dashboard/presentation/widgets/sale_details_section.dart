import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../reports/domain/entities/sale_detail_line.dart';
import '../providers/sale_details_page_provider.dart';
import '../utils/report_formatters.dart';
import 'reports_empty_state.dart';
import 'reports_error_state.dart';
import 'reports_pagination_bar.dart';

class SaleDetailsSection extends ConsumerStatefulWidget {
  final SaleDetailsRequest Function({
    required int page,
    required String orderColumn,
    required bool ascending,
    required String search,
  })
  requestBuilder;

  const SaleDetailsSection({super.key, required this.requestBuilder});

  @override
  ConsumerState<SaleDetailsSection> createState() => _SaleDetailsSectionState();
}

class _SaleDetailsSectionState extends ConsumerState<SaleDetailsSection> {
  static const _debounceDuration = Duration(milliseconds: 300);

  int _page = 0;
  String _search = '';
  Timer? _searchDebounce;

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      setState(() {
        _search = value.trim();
        _page = 0;
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.requestBuilder(
      page: _page,
      orderColumn: 'sale_date',
      ascending: false,
      search: _search,
    );

    final pageAsync = ref.watch(saleDetailsPageProvider(request));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            labelText: 'Buscar por N° de venta o producto',
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: pageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ReportsErrorState(
              message: error is Failure
                  ? error.message
                  : 'Error inesperado al cargar las ventas.',
              onRetry: () => ref.invalidate(saleDetailsPageProvider(request)),
            ),
            data: (page) {
              if (page.items.isEmpty) {
                return const ReportsEmptyState(
                  message:
                      'No se encontraron ventas para los filtros seleccionados',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${page.totalCount} '
                    '${page.totalCount == 1 ? 'resultado' : 'resultados'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: page.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _SaleCard(line: page.items[index]),
                    ),
                  ),
                  ReportsPaginationBar(
                    totalCount: page.totalCount,
                    page: _page,
                    pageSize: request.pageSize,
                    onPrevious: () => setState(() => _page--),
                    onNext: () => setState(() => _page++),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SaleCard extends StatelessWidget {
  final SaleDetailLine line;

  const _SaleCard({required this.line});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Venta ${line.number} - '
                  '${formatReportShortDate(line.saleDate)} - '
                  'Cant. ${formatReportQuantity(line.quantity)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatReportAmount(line.subtotal),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

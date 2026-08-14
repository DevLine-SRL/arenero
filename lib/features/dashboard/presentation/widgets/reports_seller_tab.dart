import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../reports/domain/entities/report_suggestion.dart';
import '../providers/reports_date_range_provider.dart';
import '../providers/reports_providers.dart';
import '../providers/sale_details_page_provider.dart';
import '../providers/selected_seller_report_provider.dart';
import '../utils/report_formatters.dart';
import 'entity_autocomplete_field.dart';
import 'report_kpi_card.dart';
import 'reports_empty_state.dart';
import 'reports_error_state.dart';
import 'sale_details_section.dart';
import 'stack_or_row.dart';

class ReportsSellerTab extends ConsumerStatefulWidget {
  const ReportsSellerTab({super.key});

  @override
  ConsumerState<ReportsSellerTab> createState() => _ReportsSellerTabState();
}

class _ReportsSellerTabState extends ConsumerState<ReportsSellerTab> {
  String? _selectedSellerId;

  void _onSelected(ReportSuggestion suggestion) {
    setState(() => _selectedSellerId = suggestion.id);
  }

  void _onCleared() {
    setState(() => _selectedSellerId = null);
  }

  @override
  Widget build(BuildContext context) {
    final range = ref.watch(reportsDateRangeProvider);
    final sellerReportAsync = ref.watch(
      selectedSellerReportProvider(_selectedSellerId),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntityAutocompleteField(
            loadSuggestions: (ref, query) async {
              final result = await ref.read(searchSellersUseCaseProvider)(
                query.trim(),
              );
              return result.fold((failure) => throw failure, (rows) => rows);
            },
            labelText: 'Vendedor',
            hintText: 'Escribe el nombre del vendedor',
            onSelected: _onSelected,
            onCleared: _onCleared,
          ),
          const SizedBox(height: 16),
          if (_selectedSellerId == null)
            const Expanded(
              child: ReportsEmptyState(
                message: 'Busca un vendedor para ver sus ventas del período',
              ),
            )
          else ...[
            sellerReportAsync.when(
              loading: () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ReportsErrorState(
                message: error is Failure
                    ? error.message
                    : 'No se pudieron cargar los datos del vendedor.',
                onRetry: () => ref.invalidate(
                  selectedSellerReportProvider(_selectedSellerId),
                ),
              ),
              data: (row) => StackOrRow(
                children: [
                  ReportKpiCard(
                    title: 'Total del período',
                    value: formatReportAmount(row?.totalSold ?? 0),
                    icon: Icons.payments_outlined,
                  ),
                  ReportKpiCard(
                    title: 'N° de ventas',
                    value: '${row?.nSales ?? 0}',
                    icon: Icons.receipt_long_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SaleDetailsSection(
                key: ValueKey('seller-$_selectedSellerId'),
                requestBuilder:
                    ({
                      required int page,
                      required String orderColumn,
                      required bool ascending,
                      required String search,
                    }) {
                      return SaleDetailsRequest(
                        startDate: range.startDate,
                        endDate: range.endDate,
                        sellerId: _selectedSellerId,
                        search: search,
                        orderColumn: orderColumn,
                        ascending: ascending,
                        page: page,
                      );
                    },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

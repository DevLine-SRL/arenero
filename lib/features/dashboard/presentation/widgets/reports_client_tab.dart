import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../reports/domain/entities/report_suggestion.dart';
import '../providers/reports_date_range_provider.dart';
import '../providers/reports_providers.dart';
import '../providers/sale_details_page_provider.dart';
import '../providers/selected_client_report_provider.dart';
import '../utils/report_formatters.dart';
import 'entity_autocomplete_field.dart';
import 'report_kpi_card.dart';
import 'reports_empty_state.dart';
import 'reports_error_state.dart';
import 'sale_details_section.dart';
import 'stack_or_row.dart';

class ReportsClientTab extends ConsumerStatefulWidget {
  const ReportsClientTab({super.key});

  @override
  ConsumerState<ReportsClientTab> createState() => _ReportsClientTabState();
}

class _ReportsClientTabState extends ConsumerState<ReportsClientTab> {
  String? _selectedClientId;

  void _onSelected(ReportSuggestion suggestion) {
    setState(() => _selectedClientId = suggestion.id);
  }

  void _onCleared() {
    setState(() => _selectedClientId = null);
  }

  @override
  Widget build(BuildContext context) {
    final range = ref.watch(reportsDateRangeProvider);
    final clientReportAsync = ref.watch(
      selectedClientReportProvider(_selectedClientId),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntityAutocompleteField(
            loadSuggestions: (ref, query) async {
              final result = await ref.read(searchClientsUseCaseProvider)(
                query.trim(),
              );
              return result.fold((failure) => throw failure, (rows) => rows);
            },
            labelText: 'Cliente',
            hintText: 'Escribe el nombre del cliente',
            onSelected: _onSelected,
            onCleared: _onCleared,
          ),
          const SizedBox(height: 16),
          if (_selectedClientId == null)
            const Expanded(
              child: ReportsEmptyState(
                message: 'Busca un cliente para ver sus ventas del período',
              ),
            )
          else ...[
            clientReportAsync.when(
              loading: () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => ReportsErrorState(
                message: error is Failure
                    ? error.message
                    : 'No se pudieron cargar los datos del cliente.',
                onRetry: () => ref.invalidate(
                  selectedClientReportProvider(_selectedClientId),
                ),
              ),
              data: (row) => StackOrRow(
                children: [
                  ReportKpiCard(
                    title: 'Total del período',
                    value: formatReportAmount(row?.total ?? 0),
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
                key: ValueKey('client-$_selectedClientId'),
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
                        clientId: _selectedClientId,
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

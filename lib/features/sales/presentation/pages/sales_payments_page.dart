import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/sale.dart';
import '../providers/cobros_search_query_provider.dart';
import '../providers/cobros_selection_provider.dart';
import '../providers/pending_sales_provider.dart';
import '../providers/sales_history_provider.dart';
import '../providers/sales_providers.dart';
import '../utils/sale_formatters.dart';
import '../widgets/cobros_empty_state.dart';
import '../widgets/cobros_search_field.dart';
import '../widgets/cobros_table.dart';

class SalesPaymentsPage extends ConsumerStatefulWidget {
  const SalesPaymentsPage({super.key});

  @override
  ConsumerState<SalesPaymentsPage> createState() => _SalesPaymentsPageState();
}

class _SalesPaymentsPageState extends ConsumerState<SalesPaymentsPage> {
  Future<void> _registerPartialPayment(Sale sale) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => _PartialPaymentDialog(sale: sale),
    );

    if (amount == null || !mounted) return;

    final newAmountPaid = sale.amountPaid + amount;
    final result = await ref.read(updateSalePaymentUseCaseProvider)(
      saleId: sale.id!,
      paymentStatus: SalePaymentStatus.partial,
      amountPaid: newAmountPaid,
      pendingAmount: sale.total - newAmountPaid,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ref.invalidate(pendingSalesDataProvider);
        ref.invalidate(salesHistoryProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Abono registrado')));
      },
    );
  }

  Future<void> _markSelectedPaid(List<Sale> selected) async {
    if (selected.isEmpty) return;

    final total = selected.fold<double>(0, (sum, s) => sum + s.pendingAmount);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cobrar total'),
        content: Text(
          '¿Cobrar ${selected.length} venta(s) por ${formatAmount(total)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cobrar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    for (final sale in selected) {
      await ref.read(updateSalePaymentUseCaseProvider)(
        saleId: sale.id!,
        paymentStatus: SalePaymentStatus.paidInFull,
        amountPaid: sale.total,
        pendingAmount: 0,
      );
    }

    if (!mounted) return;

    ref.read(cobrosSelectionProvider.notifier).clear();
    ref.invalidate(pendingSalesDataProvider);
    ref.invalidate(salesHistoryProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selected.length} venta(s) cobrada(s)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(pendingSalesDataProvider);
    final selection = ref.watch(cobrosSelectionProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: paymentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No se pudieron cargar los cobros pendientes.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(pendingSalesDataProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (allSales) {
            final query = ref.watch(cobrosSearchQueryProvider);
            final visibleSales = ref.watch(pendingSalesProvider);

            final emptyMessage = allSales.isEmpty
                ? 'No hay cobros pendientes'
                : visibleSales.isEmpty && query.trim().isNotEmpty
                ? 'Ningún cobro coincide con "$query"'
                : 'No hay cobros para el rango seleccionado';

            final selectedSales = visibleSales
                .where((s) => selection.contains(s.id))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  title: 'Cobros Pendientes',
                  description: 'Cobros pendientes de los clientes',
                  icon: Icons.credit_card_rounded,
                ),
                const SizedBox(height: 16),
                const CobrosSearchField(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: selection.isNotEmpty
                          ? () => _markSelectedPaid(selectedSales)
                          : null,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        selection.isEmpty
                            ? 'Cobrar total'
                            : 'Cobrar total (${selection.length})',
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: selection.length == 1
                          ? () => _registerPartialPayment(selectedSales.first)
                          : null,
                      icon: const Icon(Icons.add_card_rounded),
                      label: const Text('Abonar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: visibleSales.isEmpty
                      ? CobrosEmptyState(message: emptyMessage)
                      : CobrosTable(sales: visibleSales),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PartialPaymentDialog extends StatefulWidget {
  final Sale sale;

  const _PartialPaymentDialog({required this.sale});

  @override
  State<_PartialPaymentDialog> createState() => _PartialPaymentDialogState();
}

class _PartialPaymentDialogState extends State<_PartialPaymentDialog> {
  final _controller = TextEditingController();
  double _amount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _parseAmount(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final valid = _amount > 0 && _amount < widget.sale.pendingAmount;
    final showError = _controller.text.isNotEmpty && !valid;

    return AlertDialog(
      title: const Text('Registrar abono'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Saldo actual: ${formatAmount(widget.sale.pendingAmount)}'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Valor recibido',
              prefixText: 'Bs. ',
            ),
            onChanged: (value) {
              setState(() {
                _amount = _parseAmount(value);
              });
            },
          ),
          if (showError) ...[
            const SizedBox(height: 8),
            Text(
              'Debe ser mayor a Bs. 0 y menor al saldo.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: valid ? () => Navigator.of(context).pop(_amount) : null,
          child: const Text('Guardar abono'),
        ),
      ],
    );
  }
}

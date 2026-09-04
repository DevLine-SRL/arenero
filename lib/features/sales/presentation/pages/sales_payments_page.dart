import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/page_header.dart';
import '../../domain/entities/sale.dart';
import '../providers/pending_sales_provider.dart';
import '../providers/sales_history_provider.dart';
import '../providers/sales_providers.dart';
import '../utils/sale_formatters.dart';

class SalesPaymentsPage extends ConsumerWidget {
  const SalesPaymentsPage({super.key});

  Future<void> _markPaid(BuildContext context, WidgetRef ref, Sale sale) async {
    final result = await ref.read(updateSalePaymentUseCaseProvider)(
      saleId: sale.id!,
      paymentStatus: SalePaymentStatus.paidInFull,
      amountPaid: sale.total,
      pendingAmount: 0,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ref.invalidate(pendingSalesProvider);
        ref.invalidate(salesHistoryProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Venta cobrada')));
      },
    );
  }

  Future<void> _registerPartialPayment(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => _PartialPaymentDialog(sale: sale),
    );

    if (amount == null || !context.mounted) return;

    final newAmountPaid = sale.amountPaid + amount;
    final result = await ref.read(updateSalePaymentUseCaseProvider)(
      saleId: sale.id!,
      paymentStatus: SalePaymentStatus.partial,
      amountPaid: newAmountPaid,
      pendingAmount: sale.total - newAmountPaid,
    );

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ref.invalidate(pendingSalesProvider);
        ref.invalidate(salesHistoryProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Abono registrado')));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(pendingSalesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: PageHeader(
              title: 'Cobros Pendientes',
              description: 'Cobros pendientes de los clientes',
              icon: Icons.credit_card_rounded,
            ),
          ),
          Expanded(
            child: payments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar los cobros pendientes.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              data: (sales) {
                if (sales.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No hay cobros pendientes.'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return _PendingPaymentItem(
                      sale: sale,
                      onMarkPaid: () => _markPaid(context, ref, sale),
                      onRegisterPartial: () =>
                          _registerPartialPayment(context, ref, sale),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentItem extends StatelessWidget {
  final Sale sale;
  final VoidCallback onMarkPaid;
  final VoidCallback onRegisterPartial;

  const _PendingPaymentItem({
    required this.sale,
    required this.onMarkPaid,
    required this.onRegisterPartial,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPartial = sale.paymentStatus == SalePaymentStatus.partial;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta V-${sale.number ?? sale.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        sale.client.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(isPartial ? 'Con abono' : 'Pendiente'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaymentAmountRow(label: 'Total', value: formatAmount(sale.total)),
            if (sale.amountPaid > 0)
              _PaymentAmountRow(
                label: 'Abonado',
                value: formatAmount(sale.amountPaid),
              ),
            _PaymentAmountRow(
              label: 'Saldo',
              value: formatAmount(sale.pendingAmount),
              strong: true,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;
                final markPaid = FilledButton.icon(
                  onPressed: onMarkPaid,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Cobrar total'),
                );
                final partial = OutlinedButton.icon(
                  onPressed: onRegisterPartial,
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('Registrar abono'),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [markPaid, const SizedBox(height: 8), partial],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: markPaid),
                    const SizedBox(width: 10),
                    Expanded(child: partial),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentAmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _PaymentAmountRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = strong
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sale.dart';
import '../providers/register_sale_controller_provider.dart';
import '../utils/sale_formatters.dart';

class SalePaymentCollectionStep extends ConsumerStatefulWidget {
  const SalePaymentCollectionStep({super.key});

  @override
  ConsumerState<SalePaymentCollectionStep> createState() =>
      _SalePaymentCollectionStepState();
}

class _SalePaymentCollectionStepState
    extends ConsumerState<SalePaymentCollectionStep> {
  final _amountController = TextEditingController();
  SalePaymentStatus? _selectedStatus;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _parseAmount(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  void _selectStatus(SalePaymentStatus status) {
    setState(() {
      _selectedStatus = status;
      if (status != SalePaymentStatus.partial) {
        _amountController.clear();
      }
    });

    ref
        .read(registerSaleControllerProvider.notifier)
        .onPaymentStatusChanged(status);
  }

  Future<void> _confirm() async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = await ref
        .read(registerSaleControllerProvider.notifier)
        .confirmRegisteredSalePayment();

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(content: Text(failure?.message ?? 'Cobro registrado')),
    );
  }

  void _later() {
    ref.read(registerSaleControllerProvider.notifier).finishPaymentLater();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La venta queda pendiente de cobro.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(registerSaleControllerProvider);
    final sale = state.registeredSale;

    if (sale == null) {
      return const SizedBox.shrink();
    }

    final canConfirm = _selectedStatus != null && state.canConfirmPayment;
    final showPartialError =
        _selectedStatus == SalePaymentStatus.partial &&
        _amountController.text.trim().isNotEmpty &&
        !state.hasValidPartialPayment;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RegisteredSaleBanner(sale: sale),
                const SizedBox(height: 24),
                Text(
                  '¿Cómo se cobró esta venta?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Registra el pago ahora. Si no se cobró todavía, quedará en tu lista de cobros pendientes.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _PaymentOptionTile(
                  selected: _selectedStatus == SalePaymentStatus.paidInFull,
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: Colors.green,
                  title: 'Se cobró completo',
                  description:
                      'El cliente pagó el total: ${formatAmount(sale.total)}',
                  onTap: () => _selectStatus(SalePaymentStatus.paidInFull),
                ),
                const SizedBox(height: 12),
                _PaymentOptionTile(
                  selected: _selectedStatus == SalePaymentStatus.partial,
                  icon: Icons.warning_amber_rounded,
                  accentColor: Colors.amber,
                  title: 'Pago parcial (abono)',
                  description:
                      'El cliente pagó una parte. Ingresa el valor recibido.',
                  onTap: () => _selectStatus(SalePaymentStatus.partial),
                  child: _selectedStatus == SalePaymentStatus.partial
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Valor recibido',
                                prefixText: 'Bs. ',
                                isDense: true,
                              ),
                              onChanged: (value) {
                                ref
                                    .read(
                                      registerSaleControllerProvider.notifier,
                                    )
                                    .onAmountPaidChanged(_parseAmount(value));
                                setState(() {});
                              },
                            ),
                            if (showPartialError) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Debe ser mayor a Bs. 0 y menor al total.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ] else if (state.hasValidPartialPayment) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Saldo pendiente: ${formatAmount(state.pendingAmount)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                _PaymentOptionTile(
                  selected: _selectedStatus == SalePaymentStatus.pending,
                  icon: Icons.schedule_rounded,
                  accentColor: Colors.red,
                  title: 'No se cobró - queda pendiente',
                  description: 'Aparecerá en tu lista de cobros para después.',
                  onTap: () => _selectStatus(SalePaymentStatus.pending),
                ),
                if (state.submitError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.submitError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 420;
                    final confirmButton = FilledButton.icon(
                      onPressed: canConfirm ? _confirm : null,
                      icon: state.isRecordingPayment
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        state.isRecordingPayment
                            ? 'Confirmando...'
                            : 'Confirmar',
                      ),
                    );
                    final laterButton = OutlinedButton(
                      onPressed: state.isRecordingPayment ? null : _later,
                      child: const Text('Hacer después'),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          confirmButton,
                          const SizedBox(height: 10),
                          laterButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: confirmButton),
                        const SizedBox(width: 12),
                        laterButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisteredSaleBanner extends StatelessWidget {
  final Sale sale;

  const _RegisteredSaleBanner({required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final number = sale.number == null ? sale.id ?? '' : 'V-${sale.number}';

    return Material(
      color: Colors.green.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venta $number registrada',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sale.client.name} · ${formatAmount(sale.total)}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
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

class _PaymentOptionTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Widget? child;

  const _PaymentOptionTile({
    required this.selected,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = accentColor.withValues(alpha: 0.10);
    final borderColor = selected
        ? accentColor
        : theme.colorScheme.outlineVariant;

    return Material(
      color: selected
          ? selectedColor
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? accentColor.withValues(alpha: 0.16)
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? accentColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    ?child,
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

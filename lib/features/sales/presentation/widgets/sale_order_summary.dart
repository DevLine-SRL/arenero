import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/sale.dart';
import '../providers/register_sale_controller_provider.dart';
import '../utils/sale_formatters.dart';

class SaleOrderSummary extends ConsumerWidget {
  const SaleOrderSummary({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(registerSaleControllerProvider.notifier);
    final failure = await controller.submit();

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(failure?.message ?? 'Venta registrada')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(registerSaleControllerProvider);
    final user = ref.watch(authSessionProvider).value;
    final requiresSeller = user?.role == 'admin';
    final canSubmit =
        state.canSubmit && (!requiresSeller || state.seller != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              children: [
                _AmountRow(
                  label: 'Subtotal',
                  value: formatAmount(state.subtotal),
                ),
                _AmountRow(
                  label: 'Descuento',
                  value: state.discountAmount > 0
                      ? '-${formatAmount(state.discountAmount)}'
                      : formatAmount(0),
                  color: state.discountAmount > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                _AmountRow(
                  label: 'Flete',
                  value:
                      '+${formatAmount(state.deliveryMode == SaleDeliveryMode.companyDelivery ? state.freightAmount : 0)}',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const Divider(height: 18),
                _AmountRow(
                  label: 'Total',
                  value: formatAmount(state.total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (context) {
            final count = state.completedItems.length;
            return Text(
              '$count ${count == 1 ? 'producto' : 'productos'}'
              '${state.client == null ? '' : ' · ${state.client!.name}'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSubmit ? () => _submit(context, ref) : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: state.isSubmitting
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Registrando venta...'),
                    ],
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_checkout_rounded),
                      SizedBox(width: 8),
                      Text('Registrar venta'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final TextStyle? style;

  const _AmountRow({
    required this.label,
    required this.value,
    this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = style ?? theme.textTheme.titleMedium;
    final valueStyle = effectiveStyle?.copyWith(color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: effectiveStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

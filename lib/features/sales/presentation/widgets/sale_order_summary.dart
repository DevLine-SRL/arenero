import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/register_sale_controller_provider.dart';
import '../utils/sale_formatters.dart';

class SaleOrderSummary extends ConsumerWidget {
  const SaleOrderSummary({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(registerSaleControllerProvider.notifier);
    await controller.submit();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta registrada (demo)')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(registerSaleControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: theme.textTheme.titleMedium),
            Text(
              formatAmount(state.total),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
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
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: state.canSubmit
              ? () => _submit(context, ref)
              : null,
          icon: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Registrar venta'),
        ),
      ],
    );
  }
}
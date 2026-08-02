import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sellers_controller_provider.dart';
import 'create_seller_dialog.dart';

class SellersHeader extends ConsumerWidget {
  const SellersHeader({super.key});

  Future<void> _openCreateDialog(BuildContext context, WidgetRef ref) async {
    final created = await CreateSellerDialog.show(context);
    if (created == true) {
      ref.invalidate(sellersControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vendedores', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Usuarios registrados en el sistema',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: FilledButton.icon(
            onPressed: () => _openCreateDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar'),
          ),
        ),
      ],
    );
  }
}

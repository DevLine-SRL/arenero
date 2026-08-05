import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../clients/domain/entities/client.dart';
import '../providers/register_sale_controller_provider.dart';
import 'sale_client_picker_dialog.dart';

class SaleClientSelector extends ConsumerWidget {
  const SaleClientSelector({super.key});

  Future<void> _pickClient(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<Client>(
      context: context,
      builder: (context) => const SaleClientPickerDialog(),
    );
    if (selected != null) {
      ref
          .read(registerSaleControllerProvider.notifier)
          .onClientSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final client = ref.watch(
      registerSaleControllerProvider.select((state) => state.client),
    );

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _pickClient(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: client == null
              ? Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seleccionar cliente',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            'CI: ${client.ci}${client.phone != null ? ' · ${client.phone}' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Quitar cliente',
                      onPressed: () => ref
                          .read(registerSaleControllerProvider.notifier)
                          .onClearClient(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'client_status_filter.dart';

class ClientsActionsBar extends StatelessWidget {
  final ClientStatusFilter filter;
  final int selectedCount;
  final VoidCallback onEdit;
  final VoidCallback? onEnable;
  final VoidCallback? onDisable;

  const ClientsActionsBar({
    super.key,
    required this.filter,
    required this.selectedCount,
    required this.onEdit,
    required this.onEnable,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedCount > 0;

    final showEnable =
        filter == ClientStatusFilter.inactive ||
        filter == ClientStatusFilter.all;
    final showDisable =
        filter == ClientStatusFilter.active || filter == ClientStatusFilter.all;

    final hasActions = showEnable || showDisable;
    final canEdit = selectedCount == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasActions)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showEnable)
                OutlinedButton.icon(
                  onPressed: onEnable,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Habilitar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              if (showDisable)
                OutlinedButton.icon(
                  onPressed: onDisable,
                  icon: const Icon(Icons.block_rounded),
                  label: const Text('Deshabilitar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                ),
              FilledButton.icon(
                onPressed: canEdit ? onEdit : null,
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Editar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        if (hasSelection) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  '$selectedCount seleccionado${selectedCount == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'sellers_status_filter.dart';

class SellersActionsBar extends StatelessWidget {
  final SellerStatusFilter filter;
  final int selectedCount;
  final VoidCallback? onEnable;
  final VoidCallback? onDisable;

  const SellersActionsBar({
    super.key,
    required this.filter,
    required this.selectedCount,
    required this.onEnable,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedCount > 0;

    final showEnable =
        filter == SellerStatusFilter.inactive ||
        filter == SellerStatusFilter.all;
    final showDisable =
        filter == SellerStatusFilter.active || filter == SellerStatusFilter.all;

    final hasActions = showEnable || showDisable;

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
                ),
              if (showDisable)
                OutlinedButton.icon(
                  onPressed: onDisable,
                  icon: const Icon(Icons.block_rounded),
                  label: const Text('Deshabilitar'),
                ),
            ],
          ),
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

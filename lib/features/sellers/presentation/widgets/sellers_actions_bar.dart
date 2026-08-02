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
      filter == SellerStatusFilter.active ||
      filter == SellerStatusFilter.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
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
          Text(
            '$selectedCount seleccionado${selectedCount == 1 ? '' : 's'}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

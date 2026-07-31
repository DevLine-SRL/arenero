import 'package:flutter/material.dart';

class SellersActionsBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onEnable;
  final VoidCallback? onDisable;

  const SellersActionsBar({
    super.key,
    required this.selectedCount,
    required this.onEnable,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Habilitar'),
            ),
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

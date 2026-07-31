import 'package:flutter/material.dart';

class SellersHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const SellersHeader({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
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
            onPressed: onAddPressed,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar'),
          ),
        ),
      ],
    );
  }
}

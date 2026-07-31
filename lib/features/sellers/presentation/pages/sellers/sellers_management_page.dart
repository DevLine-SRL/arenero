import 'package:flutter/material.dart';

class SellersManagementPage extends StatelessWidget {
  const SellersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('Gestión de vendedores', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

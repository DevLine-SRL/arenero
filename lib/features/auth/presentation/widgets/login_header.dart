import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final String subtitle;

  const LoginHeader({super.key, this.subtitle = 'Bienvenido de vuelta'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.landscape_rounded,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 10),
        Text(
          'Arenero',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

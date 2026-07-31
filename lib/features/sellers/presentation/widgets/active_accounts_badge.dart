import 'package:flutter/material.dart';

class ActiveAccountsBadge extends StatelessWidget {
  final int activeCount;
  final int total;

  const ActiveAccountsBadge({
    super.key,
    required this.activeCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$activeCount de $total cuentas activas',
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Distintivo de estado activo/inactivo, compartido por vendedores, clientes y
/// productos para que los colores sean idénticos en todas las pantallas.
///
/// Activo en verde (`AppColors.success`), inactivo en ámbar
/// (`AppColors.warning`), con el punto indicador y píldora translúcida.
class StatusBadge extends StatelessWidget {
  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  const StatusBadge({
    super.key,
    required this.active,
    this.activeLabel = 'Activo',
    this.inactiveLabel = 'Inactivo',
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            active ? activeLabel : inactiveLabel,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

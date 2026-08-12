import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../domain/entities/sale.dart';
import '../utils/sale_formatters.dart';

/// Encabezado del detalle: volver al historial, número de venta y estado.
///
/// Vive en el cuerpo de la página y no en el `AppBar` para no tener que tocar
/// el layout compartido.
class SaleDetailTopBar extends StatelessWidget {
  final Sale sale;

  const SaleDetailTopBar({super.key, required this.sale});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(RouteNames.salesHistory);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVoid = sale.status == SaleStatus.void_;

    return Row(
      children: [
        IconButton(
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver al historial',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sale.number == null
                    ? 'Detalle de venta'
                    : 'Venta ${sale.number}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                formatDate(sale.saleDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isVoid)
          Chip(
            label: Text(sale.status.label),
            backgroundColor: theme.colorScheme.errorContainer,
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
      ],
    );
  }
}

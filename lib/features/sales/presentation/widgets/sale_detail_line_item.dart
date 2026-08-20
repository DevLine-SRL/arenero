import 'package:flutter/material.dart';

import '../../domain/entities/sale_detail.dart';
import '../utils/sale_formatters.dart';

/// Una línea de la venta.
///
/// El precio que se muestra es `detail.unitPrice`, congelado al registrar la
/// venta. Si el producto cambió de precio después, esta línea sigue mostrando
/// lo que se cobró ese día.
class SaleDetailLineItem extends StatelessWidget {
  final SaleDetail detail;

  const SaleDetailLineItem({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = formatQuantity(detail.quantity);
    final hasDiscount = detail.discount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.productName ?? 'Producto',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '$quantity ${detail.unit.shortLabel} × '
                  '${formatAmount(detail.unitPrice)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (hasDiscount)
                  Text(
                    'Descuento ${formatAmount(detail.discount)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatAmount(detail.subtotal),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/entities/sale.dart';
import '../utils/sale_formatters.dart';

/// Totales de la venta, calculados sobre los precios históricos de cada línea.
class SaleDetailTotals extends StatelessWidget {
  final Sale sale;

  const SaleDetailTotals({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gross = sale.details.fold<double>(
      0,
      (sum, detail) => sum + (detail.quantity * detail.unitPrice),
    );
    final discount = sale.details.fold<double>(
      0,
      (sum, detail) => sum + detail.discount,
    );

    return Column(
      children: [
        _Row(label: 'Subtotal', value: formatAmount(gross)),
        if (discount > 0)
          _Row(label: 'Descuentos', value: '-${formatAmount(discount)}'),
        const Divider(height: 24),
        _Row(
          label: 'Total',
          value: formatAmount(sale.total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? style;

  const _Row({required this.label, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    final effective = style ?? Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: effective),
          Text(value, style: effective),
        ],
      ),
    );
  }
}

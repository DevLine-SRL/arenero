import 'package:flutter/material.dart';

import '../../domain/entities/sale.dart';
import 'sale_section_card.dart';

/// Datos de entrega. Solo tiene sentido cuando la venta se entregó a
/// domicilio; con retiro en tienda no hay nada que mostrar.
class SaleDetailDeliveryCard extends StatelessWidget {
  final Sale sale;

  const SaleDetailDeliveryCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delivery = sale.delivery;
    final plate = delivery?.vehiclePlate;

    final rows = <Widget>[
      if (plate != null && plate.trim().isNotEmpty)
        _Field(label: 'Placa', value: plate),
    ];

    return SaleSectionCard(
      title: 'Entrega',
      child: rows.isEmpty
          ? Text(
              'Sin datos de entrega registrados.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

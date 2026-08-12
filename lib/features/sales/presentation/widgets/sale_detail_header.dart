import 'package:flutter/material.dart';

import '../../domain/entities/sale.dart';
import 'sale_section_card.dart';

/// Datos de cabecera de la venta: a quién se le vendió, quién la registró y
/// cómo se pagó.
class SaleDetailHeader extends StatelessWidget {
  final Sale sale;

  const SaleDetailHeader({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final client = sale.client;
    final nit = client.nit;
    final phone = client.phone;

    return SaleSectionCard(
      title: 'Cliente',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Nombre', value: client.name),
          _Field(label: 'CI', value: client.ci),
          if (nit != null && nit.trim().isNotEmpty)
            _Field(label: 'NIT', value: nit),
          if (phone != null && phone.trim().isNotEmpty)
            _Field(label: 'Teléfono', value: phone),
          const Divider(height: 24),
          _Field(label: 'Vendedor', value: sale.sellerName ?? 'Sin registrar'),
          _Field(label: 'Método de pago', value: sale.paymentMethod.label),
          _Field(label: 'Entrega', value: sale.deliveryMode.label),
        ],
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

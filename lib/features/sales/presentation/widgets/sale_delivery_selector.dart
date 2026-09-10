import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sale.dart';
import '../providers/register_sale_controller_provider.dart';
import 'sale_delivery_fields.dart';

class SaleDeliverySelector extends ConsumerWidget {
  const SaleDeliverySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      registerSaleControllerProvider.select((state) => state.deliveryMode),
    );
    final controller = ref.read(registerSaleControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<SaleDeliveryMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: SaleDeliveryMode.customerPickup,
              icon: Icon(Icons.storefront_outlined, size: 18),
              label: Text('Recoge en planta'),
            ),
            ButtonSegment(
              value: SaleDeliveryMode.companyDelivery,
              icon: Icon(Icons.local_shipping_outlined, size: 18),
              label: Text('Domicilio'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) {
              controller.onDeliveryModeChanged(selected.first);
            }
          },
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: theme.colorScheme.primary,
            selectedForegroundColor: theme.colorScheme.onPrimary,
            textStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SaleDeliveryFields(),
      ],
    );
  }
}

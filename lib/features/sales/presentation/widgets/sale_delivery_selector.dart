import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mock_sales_data.dart';
import '../providers/register_sale_controller_provider.dart';

class SaleDeliverySelector extends ConsumerWidget {
  const SaleDeliverySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      registerSaleControllerProvider.select((state) => state.deliveryMode),
    );
    final controller = ref.read(registerSaleControllerProvider.notifier);

    return DropdownButtonFormField<DeliveryMode>(
      key: ValueKey(mode),
      initialValue: mode,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Entrega',
        prefixIcon: Icon(Icons.local_shipping_outlined),
        isDense: true,
      ),
      items: [
        for (final option in DeliveryMode.values)
          DropdownMenuItem(
            value: option,
            child: Text(
              option.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (option) {
        if (option != null) controller.onDeliveryModeChanged(option);
      },
    );
  }
}
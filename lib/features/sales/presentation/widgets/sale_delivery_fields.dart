import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../providers/mock_sales_data.dart';
import '../providers/register_sale_controller_provider.dart';
import '../utils/sale_formatters.dart';

class SaleDeliveryFields extends ConsumerWidget {
  const SaleDeliveryFields({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Fecha de entrega',
    );
    if (picked != null) {
      ref.read(registerSaleControllerProvider.notifier).onDeliveryDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(registerSaleControllerProvider);

    if (state.deliveryMode != DeliveryMode.companyDelivery) {
      return const SizedBox.shrink();
    }

    final controller = ref.read(registerSaleControllerProvider.notifier);

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: const InputDecoration(
              label: RequiredLabel('Dirección de entrega'),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            textCapitalization: TextCapitalization.sentences,
            onChanged: controller.onDeliveryAddressChanged,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Placa del vehículo',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  onChanged: controller.onVehiclePlateChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _pickDate(context, ref),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      label: RequiredLabel('Fecha de entrega'),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      state.deliveryDate == null
                        ? 'Seleccionar'
                        : formatDate(state.deliveryDate!),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

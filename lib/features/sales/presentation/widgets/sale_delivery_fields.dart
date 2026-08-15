import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sale.dart';
import '../providers/register_sale_controller_provider.dart';

class SaleDeliveryFields extends ConsumerStatefulWidget {
  const SaleDeliveryFields({super.key});

  @override
  ConsumerState<SaleDeliveryFields> createState() =>
      _SaleDeliveryFieldsState();
}

class _SaleDeliveryFieldsState
    extends ConsumerState<SaleDeliveryFields> {
  late final TextEditingController _vehiclePlateController;
  late final TextEditingController _freightController;

  @override
  void initState() {
    super.initState();

    _vehiclePlateController = TextEditingController();
    _freightController = TextEditingController();
  }

  @override
  void dispose() {
    _vehiclePlateController.dispose();
    _freightController.dispose();
    super.dispose();
  }

  void _onFreightChanged(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');

    final value = double.tryParse(normalized) ?? 0;

    ref
        .read(registerSaleControllerProvider.notifier)
        .onFreightAmountChanged(value);
  }

  void _clearDeliveryFields() {
    _vehiclePlateController.clear();
    _freightController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SaleDeliveryMode>(
      registerSaleControllerProvider.select(
        (state) => state.deliveryMode,
      ),
      (previous, next) {
        if (next == SaleDeliveryMode.customerPickup) {
          _clearDeliveryFields();
        }
      },
    );

    final mode = ref.watch(
      registerSaleControllerProvider.select(
        (state) => state.deliveryMode,
      ),
    );

    if (mode != SaleDeliveryMode.companyDelivery) {
      return const SizedBox.shrink();
    }

    final controller = ref.read(
      registerSaleControllerProvider.notifier,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;

          final fields = [
            TextField(
              controller: _vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'Placa del vehículo',
                hintText: 'Ej: ABC-123',
                prefixIcon: Icon(
                  Icons.directions_car_outlined,
                ),
                isDense: true,
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: controller.onVehiclePlateChanged,
            ),
            TextField(
              controller: _freightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9,.]'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Valor del flete',
                helperText:
                    'Vacío o Bs. 0 no modifica el total',
                prefixText: 'Bs. ',
                prefixIcon: Icon(
                  Icons.local_shipping_outlined,
                ),
                isDense: true,
              ),
              onChanged: _onFreightChanged,
            ),
          ];

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 12),
                Expanded(child: fields[1]),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fields[0],
              const SizedBox(height: 12),
              fields[1],
            ],
          );
        },
      ),
    );
  }
}
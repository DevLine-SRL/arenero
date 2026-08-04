import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mock_sales_data.dart';
import '../providers/register_sale_controller_provider.dart';

class SalePaymentSelector extends ConsumerWidget {
  const SalePaymentSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(
      registerSaleControllerProvider.select((state) => state.paymentMethod),
    );
    final controller = ref.read(registerSaleControllerProvider.notifier);

    return DropdownButtonFormField<PaymentMethod>(
      key: ValueKey(method),
      initialValue: method,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Pago',
        prefixIcon: Icon(Icons.payments_outlined),
        isDense: true,
      ),
      items: [
        for (final option in PaymentMethod.values)
          DropdownMenuItem(
            value: option,
            child: Text(
              option.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (option) {
        if (option != null) controller.onPaymentMethodChanged(option);
      },
    );
  }
}
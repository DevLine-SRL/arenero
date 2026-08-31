import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/register_sale_controller_provider.dart';

class SaleDiscountField extends ConsumerStatefulWidget {
  const SaleDiscountField({super.key});

  @override
  ConsumerState<SaleDiscountField> createState() => _SaleDiscountFieldState();
}

class _SaleDiscountFieldState extends ConsumerState<SaleDiscountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    final normalized = raw.replaceAll(',', '.');
    final value = double.tryParse(normalized) ?? 0;
    ref
        .read(registerSaleControllerProvider.notifier)
        .onDiscountAmountChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      decoration: const InputDecoration(
        labelText: 'Descuento',
        helperText: 'Opcional, en pesos',
        prefixText: 'Bs. ',
        prefixIcon: Icon(Icons.sell_outlined),
        isDense: true,
      ),
      onChanged: _onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/register_sale_controller_provider.dart';

class SaleNotesField extends ConsumerWidget {
  const SaleNotesField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Observaciones sobre la venta (opcional)',
        isDense: true,
      ),
      minLines: 1,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      onChanged: ref
          .read(registerSaleControllerProvider.notifier)
          .onNotesChanged,
    );
  }
}

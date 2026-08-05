import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/register_sale_controller_provider.dart';

class SaleNotesField extends ConsumerWidget {
  const SaleNotesField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Notas',
        hintText: 'Observaciones sobre la venta (opcional)',
        prefixIcon: Icon(Icons.notes_rounded),
        alignLabelWithHint: true,
      ),
      minLines: 2,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      onChanged: ref
        .read(registerSaleControllerProvider.notifier)
        .onNotesChanged,
    );
  }
}

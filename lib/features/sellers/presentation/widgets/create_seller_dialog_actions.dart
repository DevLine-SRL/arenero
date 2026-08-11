import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/create_seller_form_provider.dart';

class CreateSellerDialogActions extends ConsumerWidget {
  final VoidCallback onSubmit;

  const CreateSellerDialogActions({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createSellerFormProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: state.isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: state.isValid && !state.isSubmitting ? onSubmit : null,
          child: state.isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear vendedor'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/create_seller_form_provider.dart';
import 'create_seller_dialog_actions.dart';
import 'create_seller_form_fields.dart';

class CreateSellerDialog extends ConsumerStatefulWidget {
  const CreateSellerDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const CreateSellerDialog(),
    );
  }

  @override
  ConsumerState<CreateSellerDialog> createState() => _CreateSellerDialogState();
}

class _CreateSellerDialogState extends ConsumerState<CreateSellerDialog> {
  Future<void> _submit() async {
    final created = await ref.read(createSellerFormProvider.notifier).submit();
    if (!mounted) return;
    if (created) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar vendedor'),
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
      content: SingleChildScrollView(
        child: CreateSellerFormFields(onSubmitted: _submit),
      ),
      actions: [CreateSellerDialogActions(onSubmit: _submit)],
    );
  }
}

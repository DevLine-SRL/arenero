import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/create_client_form_provider.dart';
import 'create_client_dialog_actions.dart';
import 'create_client_form_error_banner.dart';
import 'create_client_form_fields.dart';

class CreateClientDialog extends ConsumerStatefulWidget {
  const CreateClientDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const CreateClientDialog(),
    );
  }

  @override
  ConsumerState<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends ConsumerState<CreateClientDialog> {
  Future<void> _submit() async {
    final created = await ref.read(createClientFormProvider.notifier).submit();
    if (!mounted) return;
    if (created) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar cliente'),
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CreateClientFormFields(onSubmitted: _submit),
            const SizedBox(height: 16),
            const CreateClientFormErrorBanner(),
          ],
        ),
      ),
      actions: [CreateClientDialogActions(onSubmit: _submit)],
    );
  }
}

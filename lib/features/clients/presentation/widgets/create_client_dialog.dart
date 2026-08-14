import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../providers/create_client_form_provider.dart';
import 'create_client_dialog_actions.dart';
import 'create_client_form_error_banner.dart';
import 'create_client_form_fields.dart';

class CreateClientDialog extends ConsumerStatefulWidget {
  final String initialName;
  final bool returnCreatedClient;

  const CreateClientDialog({
    super.key,
    this.initialName = '',
    this.returnCreatedClient = false,
  });

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const CreateClientDialog(),
    );
  }

  static Future<Client?> showForSelection(
    BuildContext context, {
    String initialName = '',
  }) {
    return showDialog<Client>(
      context: context,
      builder: (context) => CreateClientDialog(
        initialName: initialName,
        returnCreatedClient: true,
      ),
    );
  }

  @override
  ConsumerState<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends ConsumerState<CreateClientDialog> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(createClientFormProvider.notifier)
          .reset(initialName: widget.initialName),
    );
  }

  Future<void> _submit() async {
    final notifier = ref.read(createClientFormProvider.notifier);
    final client = widget.returnCreatedClient
        ? await notifier.submitClient()
        : null;
    final created = widget.returnCreatedClient
        ? client != null
        : await notifier.submit();
    if (!mounted) return;
    if (created) {
      Navigator.of(context).pop(widget.returnCreatedClient ? client : true);
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

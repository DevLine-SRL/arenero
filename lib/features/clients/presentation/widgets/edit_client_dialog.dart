import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/validators/validators.dart' hide required;
import '../../../../shared/widgets/required_label.dart';
import '../../domain/entities/client.dart';
import '../providers/clients_search_provider.dart';

class EditClientDialog extends ConsumerStatefulWidget {
  final Client client;

  const EditClientDialog({super.key, required this.client});

  static Future<bool?> show(BuildContext context, {required Client client}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditClientDialog(client: client),
    );
  }

  @override
  ConsumerState<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends ConsumerState<EditClientDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _ciController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nitController;
  String? _nameError;
  String? _ciError;
  String? _phoneError;
  String? _nitError;
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _ciController = TextEditingController(text: widget.client.ci);
    _phoneController = TextEditingController(text: widget.client.phone ?? '');
    _nitController = TextEditingController(text: widget.client.nit ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ciController.dispose();
    _phoneController.dispose();
    _nitController.dispose();
    super.dispose();
  }

  void _validate() {
    final name = _nameController.text.trim();
    final ciValue = _ciController.text.trim();
    final phoneValue = _phoneController.text.trim();
    final nitValue = _nitController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'El nombre es obligatorio.' : null;
      _ciError = ci(ciValue);
      _phoneError = phone(phoneValue);
      _nitError = nit(nitValue);
      _submitError = null;
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final ciValue = _ciController.text.trim();
    final phoneValue = _phoneController.text.trim();
    final nitValue = _nitController.text.trim();

    _validate();
    if (_nameError != null ||
        _ciError != null ||
        _phoneError != null ||
        _nitError != null) {
      return;
    }

    setState(() => _isSubmitting = true);

    final failure = await ref
        .read(clientsSearchProvider.notifier)
        .updateClient(
          widget.client,
          name: name,
          ci: ciValue,
          phone: phoneValue.isEmpty ? null : phoneValue,
          nit: nitValue.isEmpty ? null : nitValue,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (failure == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _submitError = failure.message);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cliente'),
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                label: const RequiredLabel('Nombre completo'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
                errorText: _nameError ?? _submitError,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _validate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ciController,
              decoration: InputDecoration(
                label: const RequiredLabel('Cédula de identidad'),
                prefixIcon: const Icon(Icons.badge_outlined),
                errorText: _ciError ?? _submitError,
                errorMaxLines: 2,
                helperText: 'Complemento opcional, por ejemplo 1234567-1A',
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _validate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: const Icon(Icons.phone_outlined),
                errorText: _phoneError ?? _submitError,
                helperText: 'Opcional',
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _validate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nitController,
              decoration: InputDecoration(
                labelText: 'NIT',
                prefixIcon: const Icon(Icons.receipt_long_outlined),
                errorText: _nitError ?? _submitError,
                errorMaxLines: 2,
                helperText: 'Opcional',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _validate(),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}

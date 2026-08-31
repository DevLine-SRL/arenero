import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../../domain/entities/seller.dart';
import '../providers/sellers_controller_provider.dart';

class EditSellerDialog extends ConsumerStatefulWidget {
  final Seller seller;
  final List<Seller> sellers;

  const EditSellerDialog({
    super.key,
    required this.seller,
    required this.sellers,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Seller seller,
    required List<Seller> sellers,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditSellerDialog(
        seller: seller,
        sellers: sellers,
      ),
    );
  }

  @override
  ConsumerState<EditSellerDialog> createState() => _EditSellerDialogState();
}

class _EditSellerDialogState extends ConsumerState<EditSellerDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _nameError;
  String? _emailError;
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.seller.name ?? '');
    _emailController = TextEditingController(text: widget.seller.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    final nameError = name.isEmpty ? 'El nombre es obligatorio.' : null;
    final emailError = email.isEmpty ? 'El correo es obligatorio.' : null;

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _submitError = null;
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _validate();
      return;
    }

    setState(() => _isSubmitting = true);

    final failure = await ref
        .read(sellersControllerProvider.notifier)
        .updateSeller(widget.seller, name, email);

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
      title: const Text('Editar vendedor'),
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
                label: const RequiredLabel('Nombre'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
                errorText: _nameError ?? _submitError,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => _validate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                label: const RequiredLabel('Correo electrónico'),
                prefixIcon: const Icon(Icons.email_outlined),
                errorText: _emailError ?? _submitError,
              ),
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

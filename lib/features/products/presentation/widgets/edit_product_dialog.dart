import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/product_duplicate_guard.dart';
import '../providers/products_controller_provider.dart';

class EditProductDialog extends ConsumerStatefulWidget {
  final Product product;
  final List<Product> products;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.products,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Product product,
    required List<Product> products,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditProductDialog(product: product, products: products),
    );
  }

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  late final TextEditingController _nameController;
  bool _isSubmitting = false;
  String? _nameError;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text;
    final error = switch (normalizeProductName(name)) {
      '' => 'El nombre del producto es obligatorio.',
      _ when isDuplicateProductName(
        products: widget.products,
        name: name,
        ignoringProductId: widget.product.id,
      ) =>
        'Ya existe un producto registrado con ese nombre.',
      _ => null,
    };
    setState(() {
      _nameError = error;
      _submitError = null;
    });
    return error == null;
  }

  Future<void> _submit() async {
    if (!_validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final failure = await ref
        .read(productsControllerProvider.notifier)
        .updateProductName(widget.product, _nameController.text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (failure == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _submitError = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modificar producto'),
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(
          label: const RequiredLabel('Nombre del producto'),
          prefixIcon: const Icon(Icons.inventory_2_outlined),
          errorText: _nameError ?? _submitError,
        ),
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_nameError != null || _submitError != null) _validate();
        },
        onSubmitted: (_) => _submit(),
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

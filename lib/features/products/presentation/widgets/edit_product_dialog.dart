import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      builder: (context) =>
          EditProductDialog(product: product, products: products),
    );
  }

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  final _priceFocus = FocusNode();
  bool _isSubmitting = false;
  String? _nameError;
  String? _priceError;
  String? _submitError;

  bool get _hasPrice => widget.product.primaryUnit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.primaryUnit?.unitPrice.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  String? _validateName() {
    final name = _nameController.text;
    return switch (normalizeProductName(name)) {
      '' => 'El nombre del producto es obligatorio.',
      _
          when isDuplicateProductName(
            products: widget.products,
            name: name,
            ignoringProductId: widget.product.id,
          ) =>
        'Ya existe un producto registrado con ese nombre.',
      _ => null,
    };
  }

  String? _validatePrice() {
    if (!_hasPrice) return null;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    return switch (price) {
      null => 'Ingresa un precio válido.',
      <= 0 => 'El precio debe ser mayor a cero.',
      _ => null,
    };
  }

  bool _validate() {
    final nameError = _validateName();
    final priceError = _validatePrice();
    setState(() {
      _nameError = nameError;
      _priceError = priceError;
    });
    return nameError == null && priceError == null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _submitError = null);

    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    final primaryUnit = widget.product.primaryUnit;
    final nameFailure = await ref
        .read(productsControllerProvider.notifier)
        .updateProductName(widget.product, _nameController.text);

    if (nameFailure != null) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = nameFailure.message;
      });
      return;
    }

    if (primaryUnit != null) {
      final price = double.parse(_priceController.text.replaceAll(',', '.'));
      final priceFailure = await ref
          .read(productsControllerProvider.notifier)
          .updateProductPrice(widget.product, primaryUnit, price);

      if (priceFailure != null) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _submitError = priceFailure.message;
        });
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modificar producto'),
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              label: const RequiredLabel('Nombre del producto'),
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              errorText: _nameError,
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_nameError != null) {
                setState(() {
                  _nameError = _validateName();
                  _submitError = null;
                });
              }
            },
            onSubmitted: (_) => _priceFocus.requestFocus(),
          ),
          if (_hasPrice) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              focusNode: _priceFocus,
              decoration: InputDecoration(
                label: const RequiredLabel('Precio'),
                prefixIcon: const Icon(Icons.payments_outlined),
                prefixText: 'Bs. ',
                errorText: _priceError,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_priceError != null) {
                  setState(() {
                    _priceError = _validatePrice();
                    _submitError = null;
                  });
                }
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _submitError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
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

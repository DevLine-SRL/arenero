import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/product_duplicate_guard.dart';
import '../providers/products_controller_provider.dart';

class CreateProductDialog extends ConsumerStatefulWidget {
  final List<Product> products;

  const CreateProductDialog({super.key, required this.products});

  static Future<bool?> show(BuildContext context, List<Product> products) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CreateProductDialog(products: products),
    );
  }

  @override
  ConsumerState<CreateProductDialog> createState() =>
      _CreateProductDialogState();
}

class _CreateProductDialogState extends ConsumerState<CreateProductDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  ProductUnitOfMeasure _unit = ProductUnitOfMeasure.m3;
  bool _isSubmitting = false;
  String? _nameError;
  String? _priceError;
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validate() || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final failure = await ref
        .read(productsControllerProvider.notifier)
        .createProduct(
          name: _nameController.text,
          unit: _unit,
          unitPrice: double.parse(_priceController.text.replaceAll(',', '.')),
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (failure == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitError = failure.message);
    }
  }

  bool _validate() {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));

    final nameError = switch (normalizeProductName(name)) {
      '' => 'El nombre del producto es obligatorio.',
      _ when isDuplicateProductName(products: widget.products, name: name) =>
        'Ya existe un producto registrado con ese nombre.',
      _ => null,
    };

    final priceError = switch (price) {
      null => 'Ingresa un precio valido.',
      <= 0 => 'El precio debe ser mayor a cero.',
      _ => null,
    };

    setState(() {
      _nameError = nameError;
      _priceError = priceError;
      _submitError = null;
    });

    return nameError == null && priceError == null;
  }

  void _onNameChanged(String _) {
    if (_nameError == null && _submitError == null) return;
    _validate();
  }

  void _onPriceChanged(String _) {
    if (_priceError == null && _submitError == null) return;
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar producto'),
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 560),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                label: const RequiredLabel('Nombre del producto'),
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                errorText: _nameError,
              ),
              textInputAction: TextInputAction.next,
              onChanged: _onNameChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProductUnitOfMeasure>(
              initialValue: _unit,
              decoration: const InputDecoration(
                label: RequiredLabel('Unidad de medida'),
                prefixIcon: Icon(Icons.straighten_rounded),
              ),
              items: [
                for (final unit in ProductUnitOfMeasure.values)
                  DropdownMenuItem(value: unit, child: Text(unit.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _unit = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                label: const RequiredLabel('Precio unitario'),
                prefixIcon: const Icon(Icons.payments_outlined),
                prefixText: 'Bs ',
                errorText: _priceError,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              onChanged: _onPriceChanged,
              onSubmitted: (_) => _submit(),
            ),
            if (_submitError != null) ...[
              const SizedBox(height: 16),
              _SubmitErrorBanner(message: _submitError!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
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
          label: const Text('Registrar'),
        ),
      ],
    );
  }
}

class _SubmitErrorBanner extends StatelessWidget {
  final String message;

  const _SubmitErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

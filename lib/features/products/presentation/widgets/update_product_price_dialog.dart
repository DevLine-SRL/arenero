import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/required_label.dart';
import '../../domain/entities/product.dart';
import '../providers/products_controller_provider.dart';

class UpdateProductPriceDialog extends ConsumerStatefulWidget {
  final Product product;
  final ProductUnitPrice unit;

  const UpdateProductPriceDialog({
    super.key,
    required this.product,
    required this.unit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Product product,
    required ProductUnitPrice unit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => UpdateProductPriceDialog(product: product, unit: unit),
    );
  }

  @override
  ConsumerState<UpdateProductPriceDialog> createState() =>
      _UpdateProductPriceDialogState();
}

class _UpdateProductPriceDialogState
    extends ConsumerState<UpdateProductPriceDialog> {
  late final TextEditingController _priceController;
  bool _isSubmitting = false;
  String? _priceError;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.unit.unitPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  bool _validate() {
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final error = switch (price) {
      null => 'Ingresa un precio válido.',
      <= 0 => 'El precio debe ser mayor a cero.',
      _ => null,
    };
    setState(() {
      _priceError = error;
      _submitError = null;
    });
    return error == null;
  }

  Future<void> _submit() async {
    if (!_validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final price = double.parse(_priceController.text.replaceAll(',', '.'));
    final failure = await ref
        .read(productsControllerProvider.notifier)
        .updateProductPrice(widget.product, widget.unit, price);
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
      title: const Text('Actualizar precio'),
      content: TextField(
        controller: _priceController,
        autofocus: true,
        decoration: InputDecoration(
          label: RequiredLabel('Precio de ${widget.product.name}'),
          prefixIcon: const Icon(Icons.payments_outlined),
          prefixText: 'Bs. ',
          errorText: _priceError ?? _submitError,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_priceError != null || _submitError != null) _validate();
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
          label: const Text('Actualizar'),
        ),
      ],
    );
  }
}

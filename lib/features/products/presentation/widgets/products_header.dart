import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'create_product_dialog.dart';

class ProductsHeader extends StatelessWidget {
  final List<Product> products;
  final int activeCount;

  const ProductsHeader({
    super.key,
    required this.products,
    required this.activeCount,
  });

  Future<void> _openCreateDialog(BuildContext context) async {
    await CreateProductDialog.show(context, products);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$activeCount activo${activeCount == 1 ? '' : 's'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF7D5A3C)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: FilledButton.icon(
            onPressed: () => _openCreateDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo'),
          ),
        ),
      ],
    );
  }
}

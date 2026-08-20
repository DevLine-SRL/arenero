import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_controller_provider.dart';
import '../providers/register_sale_controller_provider.dart';
import 'sale_line_item_card.dart';

class SaleCartSection extends ConsumerWidget {
  final VoidCallback? onAddProduct;

  const SaleCartSection({super.key, this.onAddProduct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(
      registerSaleControllerProvider.select((s) => s.items),
    );

    if (items.isEmpty) {
      final products =
          ref.watch(productsControllerProvider).value ?? const <Product>[];
      final hasProducts = products.any(
        (product) => product.active && product.units.any((unit) => unit.active),
      );

      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasProducts ? onAddProduct : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                hasProducts
                    ? Icons.add_shopping_cart_rounded
                    : Icons.inventory_2_outlined,
                size: 36,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                hasProducts
                    ? 'Haz clic para agregar un producto'
                    : 'No hay productos en el catálogo',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...items.map(
            (item) => SaleLineItemCard(key: ValueKey(item.rowId), item: item),
          ),
        ],
      ),
    );
  }
}

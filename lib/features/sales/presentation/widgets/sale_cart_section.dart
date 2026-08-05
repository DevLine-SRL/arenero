import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_controller_provider.dart';
import '../providers/register_sale_controller_provider.dart';
import 'sale_line_item_card.dart';

class SaleCartSection extends ConsumerWidget {
  const SaleCartSection({super.key});

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
        (product) => product.units.any((unit) => unit.active),
      );

      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                hasProducts
                    ? Icons.shopping_cart_outlined
                    : Icons.inventory_2_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                hasProducts
                    ? 'No hay productos agregados'
                    : 'No hay productos en el catálogo',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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

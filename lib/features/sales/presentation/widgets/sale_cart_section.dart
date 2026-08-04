import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/register_sale_controller_provider.dart';
import 'sale_line_item_card.dart';

class SaleCartSection extends ConsumerWidget {
  const SaleCartSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(registerSaleControllerProvider.select((s) => s.items));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay productos agregados',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map(
            (item) => SaleLineItemCard(
              key: ValueKey(item.rowId),
              item: item,
            ),
          ),
      ],
    );
  }
}

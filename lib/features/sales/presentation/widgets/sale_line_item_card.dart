import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mock_sales_data.dart';
import '../providers/register_sale_controller_provider.dart';
import '../providers/register_sale_state.dart';
import '../utils/sale_formatters.dart';
import 'sale_compact_fields.dart';

class SaleLineItemCard extends ConsumerStatefulWidget {
  final SaleLineItem item;

  const SaleLineItemCard({super.key, required this.item});

  @override
  ConsumerState<SaleLineItemCard> createState() => _SaleLineItemCardState();
}

class _SaleLineItemCardState extends ConsumerState<SaleLineItemCard> {
  late final TextEditingController _discountController;
  late final TextEditingController _quantityController;

  SaleLineItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: item.discount.toStringAsFixed(2),
    );
    _quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  ProductEntry? get _selectedProduct {
    final productId = item.productId;
    if (productId == null) return null;
    for (final product in MockCatalog.products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  List<ProductUnitEntry> _availableUnitEntries(Set<UnitOfMeasure> usedUnits) {
    return [
      for (final entry in item.availableUnits)
        if (!usedUnits.contains(entry.unit) || entry.unit == item.unit) entry,
    ];
  }

  bool _hasAvailableUnit(
    ProductEntry product,
    Set<UnitOfMeasure>? usedUnits,
  ) {
    final used = usedUnits ?? const <UnitOfMeasure>{};
    for (final entry in product.units) {
      if (!used.contains(entry.unit)) return true;
    }
    return false;
  }

  void _changeQuantity(double value) {
    final normalized = value == value.roundToDouble() ? value.roundToDouble() : value;
    _quantityController.text = normalized.toString();
    ref
      .read(registerSaleControllerProvider.notifier)
      .changeLineQuantity(item.rowId, normalized);
  }

  void _changeDiscount(String raw) {
    final value = double.tryParse(raw.replaceAll(',', '.'));
    if (value == null) return;
    ref
      .read(registerSaleControllerProvider.notifier)
      .changeLineDiscount(item.rowId, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.read(registerSaleControllerProvider.notifier);
    final selectedProduct = _selectedProduct;
    final hasProduct = selectedProduct != null;

    final allItems = ref.watch(
      registerSaleControllerProvider.select((state) => state.items),
    );
    final usedUnits = <UnitOfMeasure>{
      for (final other in allItems)
        if (other.rowId != item.rowId &&
            other.isComplete &&
            other.productId == item.productId &&
            other.unit != null)
          other.unit!,
    };
    final availableUnits = _availableUnitEntries(usedUnits);

    final usedUnitsByProduct = <String, Set<UnitOfMeasure>>{};
    for (final other in allItems) {
      if (other.isComplete &&
          other.productId != null &&
          other.unit != null) {
        usedUnitsByProduct
          .putIfAbsent(other.productId!, () => {})
          .add(other.unit!);
      }
    }
    final selectableProducts = <ProductEntry>[
      for (final product in MockCatalog.products)
        if (product.id == selectedProduct?.id ||
            _hasAvailableUnit(product, usedUnitsByProduct[product.id]))
          product,
    ];

    final linePrice =
        item.isComplete ? item.quantity * item.unitPrice : null;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProductEntry>(
                    key: ValueKey('product-${item.rowId}-${item.productId}'),
                    initialValue: selectedProduct,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                      isDense: true,
                    ),
                    items: [
                      for (final product in selectableProducts)
                        DropdownMenuItem(
                          value: product,
                          child: Text(
                            product.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (product) {
                      if (product != null) {
                        controller.changeLineProduct(item.rowId, product);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Quitar producto',
                    color: theme.colorScheme.error,
                    onPressed: () => controller.removeLine(item.rowId),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<UnitOfMeasure>(
                    key: ValueKey('unit-${item.rowId}-${item.unit}'),
                    initialValue: item.unit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      prefixIcon: Icon(Icons.straighten_rounded),
                      isDense: true,
                    ),
                    items: [
                      for (final entry in availableUnits)
                        DropdownMenuItem(
                          value: entry.unit,
                          child: Text(
                            '${entry.unit.label} · ${formatAmount(entry.unitPrice)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: hasProduct
                        ? (unit) {
                            if (unit != null) {
                              controller.changeLineUnit(item.rowId, unit);
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: QuantityStepper(
                    controller: _quantityController,
                    onDecrement: () => _changeQuantity(item.quantity - 1),
                    onIncrement: () => _changeQuantity(item.quantity + 1),
                    onChanged: _changeQuantity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReadOnlyAmount(
                    label: 'Precio',
                    value: linePrice == null ? '—' : formatAmount(linePrice),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descuento',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          isDense: true,
                        ),
                        onChanged: _changeDiscount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ReadOnlyAmount(
                    label: 'Subtotal',
                    value: item.isComplete ? formatAmount(item.subtotal) : '—',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

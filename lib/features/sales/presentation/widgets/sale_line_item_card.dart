import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_controller_provider.dart';
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
    _quantityController = TextEditingController(text: item.quantity.toString());
  }

  @override
  void dispose() {
    _discountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  List<ProductUnitPrice> _availableUnitEntries(
    Set<ProductUnitOfMeasure> usedUnits,
  ) {
    return [
      for (final entry in item.availableUnits)
        if (!usedUnits.contains(entry.unit) || entry.unit == item.unit) entry,
    ];
  }

  bool _hasAvailableUnit(
    Product product,
    Set<ProductUnitOfMeasure>? usedUnits,
  ) {
    if (!product.active) return false;

    final used = usedUnits ?? const <ProductUnitOfMeasure>{};
    for (final entry in product.units) {
      if (entry.active && !used.contains(entry.unit)) return true;
    }
    return false;
  }

  void _stepQuantity(double value) {
    final clamped = value < 1 ? 1.0 : value;
    final normalized = clamped == clamped.roundToDouble()
        ? clamped.roundToDouble()
        : clamped;
    _quantityController.text = normalized.toString();
    ref
        .read(registerSaleControllerProvider.notifier)
        .changeLineQuantity(item.rowId, normalized);
  }

  void _onQuantityText(String raw) {
    final value = double.tryParse(raw.replaceAll(',', '.'));
    if (value == null) return;
    if (value < 1) {
      ref
          .read(registerSaleControllerProvider.notifier)
          .changeLineQuantity(item.rowId, 1);
      return;
    }
    ref
        .read(registerSaleControllerProvider.notifier)
        .changeLineQuantity(item.rowId, value);
  }

  void _changeDiscount(String raw) {
    final value = double.tryParse(raw.replaceAll(',', '.'));
    if (value == null) return;
    final maxDiscount = item.quantity * item.unitPrice;
    final clamped = value.clamp(0.0, maxDiscount).toDouble();
    if (clamped != value) {
      _discountController.text = clamped.toStringAsFixed(2);
    }
    ref
        .read(registerSaleControllerProvider.notifier)
        .changeLineDiscount(item.rowId, clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.read(registerSaleControllerProvider.notifier);
    final productsAsync = ref.watch(productsControllerProvider);

    final products = productsAsync.value ?? const <Product>[];
    final selectedProduct = products
        .where((product) => product.id == item.productId)
        .firstOrNull;
    final hasProduct = selectedProduct != null;

    final allItems = ref.watch(
      registerSaleControllerProvider.select((state) => state.items),
    );
    final usedUnits = <ProductUnitOfMeasure>{
      for (final other in allItems)
        if (other.rowId != item.rowId &&
            other.isComplete &&
            other.productId == item.productId &&
            other.unit != null)
          other.unit!,
    };
    final availableUnits = _availableUnitEntries(usedUnits);

    final usedUnitsByProduct = <String, Set<ProductUnitOfMeasure>>{};
    for (final other in allItems) {
      if (other.isComplete && other.productId != null && other.unit != null) {
        usedUnitsByProduct
            .putIfAbsent(other.productId!, () => {})
            .add(other.unit!);
      }
    }
    final selectableProducts = <Product>[
      for (final product in products)
        if (product.id == selectedProduct?.id ||
            _hasAvailableUnit(product, usedUnitsByProduct[product.id]))
          product,
    ];

    final linePrice = item.isComplete ? item.quantity * item.unitPrice : null;

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
                  child: DropdownButtonFormField<Product>(
                    key: ValueKey('product-${item.rowId}-${item.productId}'),
                    initialValue: selectedProduct,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Producto',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      isDense: true,
                      helperText: productsAsync.isLoading
                          ? 'Cargando productos…'
                          : productsAsync.hasError
                          ? 'No se pudieron cargar los productos'
                          : null,
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
                    onChanged: productsAsync.hasValue
                        ? (product) {
                            if (product != null) {
                              controller.changeLineProduct(item.rowId, product);
                            }
                          }
                        : null,
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
                  child: DropdownButtonFormField<ProductUnitOfMeasure>(
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
                    onDecrement: () => _stepQuantity(item.quantity - 1),
                    onIncrement: () => _stepQuantity(item.quantity + 1),
                    onChanged: _onQuantityText,
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

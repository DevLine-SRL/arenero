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
  late final TextEditingController _quantityController;

  SaleLineItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: item.quantity.toString());
  }

  @override
  void dispose() {
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
    ref
        .read(registerSaleControllerProvider.notifier)
        .changeLineQuantity(item.rowId, value < 1 ? 1 : value);
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

    final subtotal = item.isComplete ? item.subtotal : null;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductSelector(
              item: item,
              productsAsync: productsAsync,
              selectableProducts: selectableProducts,
              selectedProduct: selectedProduct,
              onChanged: (product) =>
                  controller.changeLineProduct(item.rowId, product),
              onRemove: () => controller.removeLine(item.rowId),
            ),
            const SizedBox(height: 12),
            _UnitAndQuantityRow(
              item: item,
              availableUnits: availableUnits,
              hasProduct: hasProduct,
              quantityController: _quantityController,
              onUnitChanged: (unit) =>
                  controller.changeLineUnit(item.rowId, unit),
              onQuantityChanged: _onQuantityText,
              onDecrement: () => _stepQuantity(item.quantity - 1),
              onIncrement: () => _stepQuantity(item.quantity + 1),
            ),
            const SizedBox(height: 12),
            _AmountsRow(item: item, subtotal: subtotal),
          ],
        ),
      ),
    );
  }
}

class _ProductSelector extends StatelessWidget {
  final SaleLineItem item;
  final AsyncValue<List<Product>> productsAsync;
  final List<Product> selectableProducts;
  final Product? selectedProduct;
  final ValueChanged<Product> onChanged;
  final VoidCallback onRemove;

  const _ProductSelector({
    required this.item,
    required this.productsAsync,
    required this.selectableProducts,
    required this.selectedProduct,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: productsAsync.hasValue ? () => _openPicker(context) : null,
            child: InputDecorator(
              isEmpty: selectedProduct == null,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Producto',
                hintText: 'Seleccionar producto',
                prefixIcon: selectedProduct != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Icon(Icons.inventory_2_outlined),
                      ),
                suffixIcon: productsAsync.isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : productsAsync.hasError
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_drop_down_rounded),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              child: selectedProduct != null
                  ? Text(
                      selectedProduct!.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Quitar producto',
            color: theme.colorScheme.error,
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProductPickerSheet(
        products: selectableProducts,
        selected: selectedProduct,
        onSelect: (product) {
          Navigator.of(context).pop();
          onChanged(product);
        },
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final Product? selected;
  final ValueChanged<Product> onSelect;

  const _ProductPickerSheet({
    required this.products,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    if (_query.isEmpty) return widget.products;
    final q = _query.toLowerCase();
    return widget.products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No hay productos disponibles'
                        : 'Sin resultados para "$_query"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final isSelected = product.id == widget.selected?.id;
                    final activeUnits = product.units
                        .where((u) => u.active)
                        .toList();

                    return ListTile(
                      leading: Icon(
                        Icons.inventory_2_outlined,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                      title: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        activeUnits
                            .map(
                              (u) =>
                                  '${u.unit.shortLabel} ${formatAmount(u.unitPrice)}',
                            )
                            .join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => widget.onSelect(product),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UnitAndQuantityRow extends StatelessWidget {
  final SaleLineItem item;
  final List<ProductUnitPrice> availableUnits;
  final bool hasProduct;
  final TextEditingController quantityController;
  final ValueChanged<ProductUnitOfMeasure> onUnitChanged;
  final ValueChanged<String> onQuantityChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _UnitAndQuantityRow({
    required this.item,
    required this.availableUnits,
    required this.hasProduct,
    required this.quantityController,
    required this.onUnitChanged,
    required this.onQuantityChanged,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final unitField = DropdownButtonFormField<ProductUnitOfMeasure>(
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
                  entry.unit.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged:
              hasProduct && availableUnits.length > 1
                  ? (unit) {
                      if (unit != null) onUnitChanged(unit);
                    }
                  : null,
        );
        final quantityField = QuantityStepper(
          controller: quantityController,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
          onChanged: onQuantityChanged,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: unitField),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: quantityField,
            ),
          ],
        );
      },
    );
  }
}

class _AmountsRow extends StatelessWidget {
  final SaleLineItem item;
  final double? subtotal;

  const _AmountsRow({required this.item, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          ReadOnlyAmount(
            label: 'Precio unitario',
            value: item.isComplete ? formatAmount(item.unitPrice) : '-',
          ),
          ReadOnlyAmount(
            label: 'Subtotal',
            value: subtotal == null ? '-' : formatAmount(subtotal!),
          ),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 12),
            Expanded(child: fields[1]),
          ],
        );
      },
    );
  }
}

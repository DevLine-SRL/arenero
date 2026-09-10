import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../providers/products_selection_provider.dart';

class ProductsTable extends ConsumerWidget {
  final List<Product> products;

  const ProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(productsSelectionProvider);
    final allIds = products.map((p) => p.id).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveWidth =
            availableWidth < _ProductsTableRow.minContentWidth
            ? _ProductsTableRow.minContentWidth
            : availableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProductsTableHeader(
                    allSelected:
                        allIds.isNotEmpty && allIds.every(selection.contains),
                    onToggleAll: () => ref
                        .read(productsSelectionProvider.notifier)
                        .toggleAll(allIds),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductsTableRow(
                          product: product,
                          isSelected: selection.contains(product.id),
                          onToggle: () => ref
                              .read(productsSelectionProvider.notifier)
                              .toggle(product.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductsTableHeader extends StatelessWidget {
  final bool allSelected;
  final VoidCallback onToggleAll;

  const _ProductsTableHeader({
    required this.allSelected,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: _ProductsTableRow.checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (_) => onToggleAll(),
                ),
              ),
            ),
            const SizedBox(width: _ProductsTableRow.checkboxGap),
            const Expanded(child: Text('Producto')),
            const SizedBox(width: _ProductsTableRow.columnGap),
            SizedBox(
              width: _ProductsTableRow.statusDotWidth,
              child: Align(alignment: Alignment.center, child: Text('Estado')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsTableRow extends StatelessWidget {
  static const checkboxColumnWidth = 20.0;
  static const statusDotWidth = 45.0;
  static const columnGap = 8.0;
  static const horizontalPadding = 16.0;
  static const checkboxGap = 16.0;

  static const minContentWidth =
      checkboxColumnWidth +
      checkboxGap +
      columnGap +
      statusDotWidth +
      horizontalPadding;

  final Product product;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ProductsTableRow({
    required this.product,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      hoverColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                ),
              ),
            ),
            const SizedBox(width: checkboxGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.primaryUnit != null)
                    Text(
                      '${product.primaryUnit!.unit.label} · ${_formatCurrency(product.primaryUnit!.unitPrice)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Sin unidad registrada',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: columnGap),
            SizedBox(
              width: statusDotWidth,
              child: Align(
                alignment: Alignment.center,
                child: _StatusDot(active: product.active),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double value) {
    final rounded = value.round();
    final text = rounded.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Bs. $text';
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;

  const _StatusDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.error;

    return Tooltip(
      message: active ? 'Activo' : 'Inactivo',
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

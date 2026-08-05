import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductsTable extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<ProductActiveChange> onActiveChanged;

  const ProductsTable({
    super.key,
    required this.products,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < 720
            ? 720.0
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1D4C1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _ProductsTableHeader(),
                  const Divider(height: 24, color: Color(0xFFE9DECE)),
                  for (var index = 0; index < products.length; index++) ...[
                    _ProductTableRow(
                      product: products[index],
                      onActiveChanged: (active) => onActiveChanged(
                        ProductActiveChange(products[index], active),
                      ),
                    ),
                    if (index != products.length - 1)
                      const Divider(height: 1, color: Color(0xFFEDE3D4)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProductActiveChange {
  final Product product;
  final bool active;

  const ProductActiveChange(this.product, this.active);
}

class _ProductsTableHeader extends StatelessWidget {
  const _ProductsTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 30, child: _HeaderText('Nombre')),
        Expanded(flex: 16, child: _HeaderText('Unidad')),
        Expanded(flex: 18, child: _HeaderText('Precio')),
        Expanded(flex: 36, child: _HeaderText('Estado')),
      ],
    );
  }
}

class _ProductTableRow extends StatelessWidget {
  final Product product;
  final ValueChanged<bool> onActiveChanged;

  const _ProductTableRow({
    required this.product,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primaryUnit = product.primaryUnit;

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            flex: 30,
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: primaryUnit == null
                  ? const _MutedText('Sin unidad')
                  : _UnitBadge(primaryUnit.unit.shortLabel),
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              primaryUnit == null
                  ? '-'
                  : _formatCurrency(primaryUnit.unitPrice),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 36,
            child: Row(
              children: [
                _ProductToggle(
                  active: product.active,
                  onChanged: onActiveChanged,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MutedText(
                    product.active
                        ? 'Disponible para ventas'
                        : 'No aparece en ventas nuevas',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final rounded = value.round();
    final text = rounded.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Bs. $text';
  }
}

class _HeaderText extends StatelessWidget {
  final String label;

  const _HeaderText(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF7D5A3C),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  final String value;

  const _MutedText(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8C6B4D)),
    );
  }
}

class _UnitBadge extends StatelessWidget {
  final String label;

  const _UnitBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDFC9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF8C6B4D),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProductToggle extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onChanged;

  const _ProductToggle({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(!active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF7B4318) : const Color(0xFFCAB8A2),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

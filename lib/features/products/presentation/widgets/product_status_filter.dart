import 'package:flutter/material.dart';

enum ProductStatusFilter { active, inactive, all }

class ProductStatusFilterBar extends StatelessWidget {
  final ProductStatusFilter value;
  final int activeCount;
  final int inactiveCount;
  final int total;
  final ValueChanged<ProductStatusFilter> onChanged;

  const ProductStatusFilterBar({
    super.key,
    required this.value,
    required this.activeCount,
    required this.inactiveCount,
    required this.total,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<ProductStatusFilter>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.selected)
                  ? colorScheme.primary
                  : colorScheme.outline,
            ),
          ),
        ),
        segments: [
          ButtonSegment(
            value: ProductStatusFilter.active,
            label: Text('Activos ($activeCount)'),
          ),
          ButtonSegment(
            value: ProductStatusFilter.inactive,
            label: Text('Inactivos ($inactiveCount)'),
          ),
          ButtonSegment(
            value: ProductStatusFilter.all,
            label: Text('Todos ($total)'),
          ),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}

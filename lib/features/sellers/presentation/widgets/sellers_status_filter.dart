import 'package:flutter/material.dart';

enum SellerStatusFilter { active, inactive, all }

class SellersStatusFilter extends StatelessWidget {
  final SellerStatusFilter value;
  final int activeCount;
  final int inactiveCount;
  final int total;
  final ValueChanged<SellerStatusFilter> onChanged;

  const SellersStatusFilter({
    super.key,
    required this.value,
    required this.activeCount,
    required this.inactiveCount,
    required this.total,
    required this.onChanged,
  });

  String _labelOf(SellerStatusFilter filter) => switch (filter) {
        SellerStatusFilter.active => 'Activos ($activeCount)',
        SellerStatusFilter.inactive => 'Inactivos ($inactiveCount)',
        SellerStatusFilter.all => 'Todos ($total)',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SellerStatusFilter>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.filter_list_rounded, color: colorScheme.primary),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
          borderRadius: BorderRadius.circular(8),
          items: [
            for (final filter in SellerStatusFilter.values)
              DropdownMenuItem(
                value: filter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconOf(filter),
                      size: 18,
                      color: value == filter
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(_labelOf(filter)),
                  ],
                ),
              ),
          ],
          onChanged: (filter) {
            if (filter != null) onChanged(filter);
          },
        ),
      ),
    );
  }

  IconData _iconOf(SellerStatusFilter filter) => switch (filter) {
        SellerStatusFilter.active => Icons.check_circle_outline_rounded,
        SellerStatusFilter.inactive => Icons.block_rounded,
        SellerStatusFilter.all => Icons.people_rounded,
      };
}

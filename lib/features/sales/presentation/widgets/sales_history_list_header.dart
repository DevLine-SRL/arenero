import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/sales_history_sort_provider.dart';
import 'sales_history_list_item.dart';

class SalesHistoryListHeader extends ConsumerWidget {
  const SalesHistoryListHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w700,
    );
    final sort = ref.watch(salesHistorySortProvider);
    final notifier = ref.read(salesHistorySortProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: SalesHistoryListItem.numberColumnWidth,
            child: _SortableHeaderCell(
              label: 'Nº venta',
              style: style,
              sort: sort,
              field: SalesHistorySortField.number,
              onTap: () => notifier.toggle(SalesHistorySortField.number),
            ),
          ),
          Expanded(
            child: _SortableHeaderCell(
              label: 'Cliente',
              style: style,
              sort: sort,
              field: SalesHistorySortField.client,
              onTap: () => notifier.toggle(SalesHistorySortField.client),
            ),
          ),
          const SizedBox(width: SalesHistoryListItem.columnGap),
          SizedBox(
            width: SalesHistoryListItem.totalColumnWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: _SortableHeaderCell(
                label: 'Precio',
                style: style,
                sort: sort,
                field: SalesHistorySortField.total,
                alignEnd: true,
                onTap: () => notifier.toggle(SalesHistorySortField.total),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortableHeaderCell extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final SalesHistorySortOption? sort;
  final SalesHistorySortField field;
  final bool alignEnd;
  final VoidCallback onTap;

  const _SortableHeaderCell({
    required this.label,
    required this.style,
    required this.sort,
    required this.field,
    required this.onTap,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = sort?.field == field;
    final activeStyle = style?.copyWith(color: colorScheme.primary);
    final iconColor = active
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.8);

    final icon = active
        ? sort!.direction == SalesHistorySortDirection.ascending
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded
        : Icons.swap_vert_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: active ? activeStyle : style,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }
}

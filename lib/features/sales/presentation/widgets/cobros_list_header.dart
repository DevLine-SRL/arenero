import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/cobros_sort_provider.dart';
import 'cobros_list_item.dart';

class CobrosListHeader extends ConsumerWidget {
  const CobrosListHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w700,
    );
    final sort = ref.watch(cobrosSortProvider);
    final notifier = ref.read(cobrosSortProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CobrosListItem.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: CobrosListItem.numberColumnWidth,
            child: _SortableHeaderCell(
              label: 'Nº venta',
              style: style,
              sort: sort,
              field: CobrosSortField.number,
              onTap: () => notifier.toggle(CobrosSortField.number),
            ),
          ),
          Expanded(
            child: _SortableHeaderCell(
              label: 'Cliente',
              style: style,
              sort: sort,
              field: CobrosSortField.client,
              onTap: () => notifier.toggle(CobrosSortField.client),
            ),
          ),
          const SizedBox(width: CobrosListItem.columnGap),
          SizedBox(
            width: CobrosListItem.pendingAmountColumnWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: _SortableHeaderCell(
                label: 'Saldo',
                style: style,
                sort: sort,
                field: CobrosSortField.pendingAmount,
                alignEnd: true,
                onTap: () => notifier.toggle(CobrosSortField.pendingAmount),
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
  final CobrosSortOption? sort;
  final CobrosSortField field;
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
        ? sort!.direction == CobrosSortDirection.ascending
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

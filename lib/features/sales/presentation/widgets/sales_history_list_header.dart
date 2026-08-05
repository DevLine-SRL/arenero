import 'package:flutter/material.dart';

import 'sales_history_list_item.dart';

class SalesHistoryListHeader extends StatelessWidget {
  const SalesHistoryListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return SizedBox(
      width: SalesHistoryListItem.contentWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: SalesHistoryListItem.numberColumnWidth,
              child: Text('Nº venta', style: style),
            ),
            SizedBox(
              width: SalesHistoryListItem.clientColumnWidth,
              child: Text('Cliente', style: style, maxLines: 1),
            ),
            SizedBox(
              width: SalesHistoryListItem.totalColumnWidth,
              child: Text('Total', style: style, textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}

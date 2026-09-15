import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sale_history_item.dart';
import '../utils/sale_formatters.dart';
import 'sales_history_list_header.dart';
import 'sales_history_list_item.dart';

class SalesHistoryTable extends StatelessWidget {
  const SalesHistoryTable({super.key, required this.sales});

  final List<SaleHistoryItem> sales;

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.outline.withValues(alpha: 0.4);
    final total = sales.fold(0.0, (sum, item) => sum + item.total);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveWidth =
            availableWidth < SalesHistoryListItem.minContentWidth
            ? SalesHistoryListItem.minContentWidth
            : availableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SalesHistoryListHeader(),
                  Divider(height: 1, color: borderColor),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: sales.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: borderColor),
                      itemBuilder: (context, index) =>
                          SalesHistoryListItem(sale: sales[index]),
                    ),
                  ),
                  Divider(height: 1, color: borderColor),
                  _SalesHistoryTableFooter(total: total),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SalesHistoryTableFooter extends StatelessWidget {
  const _SalesHistoryTableFooter({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: SalesHistoryListItem.numberColumnWidth,
            child: Text('Total', style: style),
          ),
          const SizedBox(width: SalesHistoryListItem.columnGap),
          Expanded(
            child: Text(
              formatAmount(total),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/entities/sale.dart';
import '../utils/sale_formatters.dart';

class SalesHistoryListItem extends StatelessWidget {
  static const numberColumnWidth = 96.0;
  static const clientColumnWidth = 180.0;
  static const totalColumnWidth = 120.0;
  static const horizontalPadding = 16.0;
  static const borderWidth = 2.0;
  static const contentWidth =
      numberColumnWidth +
      clientColumnWidth +
      totalColumnWidth +
      horizontalPadding +
      borderWidth;
  final Sale sale;

  const SalesHistoryListItem({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: contentWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: numberColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sale.number}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  formatDate(sale.saleDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: clientColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.client.name,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'CI ${sale.client.ci}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: totalColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatAmount(sale.total),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sale.paymentMethod.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

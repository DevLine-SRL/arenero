import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sale.dart';
import '../utils/sale_formatters.dart';

class CobrosListItem extends StatelessWidget {
  static const numberColumnWidth = 89.0;
  static const minClientWidth = 50.0;
  static const pendingAmountColumnWidth = 106.0;
  static const horizontalPadding = 16.0;
  static const columnGap = 12.0;

  static const minContentWidth =
      numberColumnWidth +
      minClientWidth +
      columnGap +
      pendingAmountColumnWidth +
      horizontalPadding;

  final Sale sale;
  final VoidCallback onMarkPaid;
  final VoidCallback onRegisterPartial;

  const CobrosListItem({
    super.key,
    required this.sale,
    required this.onMarkPaid,
    required this.onRegisterPartial,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.goNamed(
        RouteNames.saleDetail,
        pathParameters: {'id': sale.id!},
      ),
      hoverColor: AppColors.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: numberColumnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${sale.number ?? sale.id}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.client.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
                const SizedBox(width: columnGap),
                SizedBox(
                  width: pendingAmountColumnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatAmount(sale.pendingAmount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (sale.amountPaid > 0)
                        Text(
                          'Abonado ${formatAmount(sale.amountPaid)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Cobrar total'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRegisterPartial,
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text('Abonar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

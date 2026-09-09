import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sale.dart';
import 'cobros_list_header.dart';
import 'cobros_list_item.dart';

class CobrosTable extends StatelessWidget {
  final List<Sale> sales;
  final void Function(Sale sale) onMarkPaid;
  final void Function(Sale sale) onRegisterPartial;

  const CobrosTable({
    super.key,
    required this.sales,
    required this.onMarkPaid,
    required this.onRegisterPartial,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.outline.withValues(alpha: 0.4);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveWidth = availableWidth < CobrosListItem.minContentWidth
            ? CobrosListItem.minContentWidth
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
                  const CobrosListHeader(),
                  Divider(height: 1, color: borderColor),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: sales.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: borderColor),
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        return CobrosListItem(
                          sale: sale,
                          onMarkPaid: () => onMarkPaid(sale),
                          onRegisterPartial: () => onRegisterPartial(sale),
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

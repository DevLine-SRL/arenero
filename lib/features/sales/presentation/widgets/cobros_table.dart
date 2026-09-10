import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sale.dart';
import '../providers/cobros_selection_provider.dart';
import 'cobros_list_header.dart';
import 'cobros_list_item.dart';

class CobrosTable extends ConsumerWidget {
  final List<Sale> sales;

  const CobrosTable({super.key, required this.sales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = AppColors.outline.withValues(alpha: 0.4);
    final selection = ref.watch(cobrosSelectionProvider);
    final allIds = sales.map((s) => s.id!).toList();

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
                  CobrosListHeader(allIds: allIds),
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
                          isSelected: selection.contains(sale.id),
                          onToggled: (_) {
                            ref
                                .read(cobrosSelectionProvider.notifier)
                                .toggle(sale.id!);
                          },
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

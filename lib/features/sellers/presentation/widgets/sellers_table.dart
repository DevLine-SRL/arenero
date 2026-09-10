import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/seller.dart';
import '../providers/sellers_selection_provider.dart';

class SellersTable extends ConsumerWidget {
  final List<Seller> sellers;

  const SellersTable({super.key, required this.sellers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(sellersSelectionProvider);
    final allIds = sellers.map((s) => s.id).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveWidth = availableWidth < _SellersTableRow.minContentWidth
            ? _SellersTableRow.minContentWidth
            : availableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SellersTableHeader(
                    allSelected:
                        allIds.isNotEmpty && allIds.every(selection.contains),
                    onToggleAll: () => ref
                        .read(sellersSelectionProvider.notifier)
                        .toggleAll(allIds),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      itemCount: sellers.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final seller = sellers[index];
                        return _SellersTableRow(
                          seller: seller,
                          isSelected: selection.contains(seller.id),
                          onToggle: () => ref
                              .read(sellersSelectionProvider.notifier)
                              .toggle(seller.id),
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

class _SellersTableHeader extends StatelessWidget {
  final bool allSelected;
  final VoidCallback onToggleAll;

  const _SellersTableHeader({
    required this.allSelected,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: _SellersTableRow.checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (_) => onToggleAll(),
                ),
              ),
            ),
            const SizedBox(width: _SellersTableRow.checkboxGap),
            const Expanded(child: Text('Vendedor')),
            const SizedBox(width: _SellersTableRow.columnGap),
            SizedBox(
              width: _SellersTableRow.statusDotWidth,
              child: Align(alignment: Alignment.center, child: Text('Estado')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellersTableRow extends StatelessWidget {
  static const checkboxColumnWidth = 20.0;
  static const statusDotWidth = 45.0;
  static const columnGap = 8.0;
  static const horizontalPadding = 16.0;
  static const checkboxGap = 16.0;

  static const minContentWidth =
      checkboxColumnWidth +
      checkboxGap +
      columnGap +
      statusDotWidth +
      horizontalPadding;

  final Seller seller;
  final bool isSelected;
  final VoidCallback onToggle;

  const _SellersTableRow({
    required this.seller,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      hoverColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: checkboxColumnWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                ),
              ),
            ),
            const SizedBox(width: checkboxGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (seller.name != null)
                    Text(
                      seller.name!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    seller.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: columnGap),
            SizedBox(
              width: statusDotWidth,
              child: Align(
                alignment: Alignment.center,
                child: _StatusDot(active: seller.active),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;

  const _StatusDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.error;

    return Tooltip(
      message: active ? 'Activo' : 'Inactivo',
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

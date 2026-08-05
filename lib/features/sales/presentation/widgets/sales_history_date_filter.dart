import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_history_date_range_provider.dart';
import '../utils/sale_formatters.dart';

class SalesHistoryDateFilter extends ConsumerWidget {
  const SalesHistoryDateFilter({super.key});

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref, {
    required bool isStart,
  }) async {
    final range = ref.read(salesHistoryDateRangeProvider);
    final now = DateTime.now();
    final initial = isStart ? (range.startDate ?? now) : (range.endDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;
    if (!context.mounted) return;

    final start = isStart ? picked : range.startDate;
    final end = isStart ? range.endDate : picked;
    if (start != null && end != null && start.isAfter(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isStart
                ? 'La fecha de inicio no puede ser posterior a la de fin.'
                : 'La fecha de fin no puede ser anterior a la de inicio.',
          ),
        ),
      );
      return;
    }

    final notifier = ref.read(salesHistoryDateRangeProvider.notifier);
    if (isStart) {
      notifier.onStartChanged(picked);
    } else {
      notifier.onEndChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(salesHistoryDateRangeProvider);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickDate(context, ref, isStart: true),
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(
              range.startDate != null
                  ? 'Inicio ${formatDate(range.startDate!)}'
                  : 'Inicio',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickDate(context, ref, isStart: false),
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(
              range.endDate != null
                  ? 'Fin ${formatDate(range.endDate!)}'
                  : 'Fin',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (range.isActive) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () =>
                ref.read(salesHistoryDateRangeProvider.notifier).clear(),
            tooltip: 'Quitar filtro de fechas',
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ],
    );
  }
}

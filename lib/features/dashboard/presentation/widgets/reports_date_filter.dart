import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reports_date_range_provider.dart';
import '../utils/report_formatters.dart';

bool applyReportDateSelection(
  BuildContext context,
  ProviderContainer container, {
  required DateTime picked,
  required bool isStart,
}) {
  final range = container.read(reportsDateRangeProvider);
  final start = isStart ? picked : range.startDate;
  final end = isStart ? range.endDate : picked;
  if (start.isAfter(end)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isStart
              ? 'La fecha de inicio no puede ser posterior a la de fin.'
              : 'La fecha de fin no puede ser anterior a la de inicio.',
        ),
      ),
    );
    return false;
  }

  final notifier = container.read(reportsDateRangeProvider.notifier);
  if (isStart) {
    notifier.onStartChanged(picked);
  } else {
    notifier.onEndChanged(picked);
  }
  return true;
}

class ReportsDateFilter extends ConsumerWidget {
  const ReportsDateFilter({super.key});

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref, {
    required bool isStart,
  }) async {
    final range = ref.read(reportsDateRangeProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? range.startDate : range.endDate,
      firstDate: isStart
          ? DateTime(range.startDate.year - 10)
          : range.startDate,
      lastDate: isStart ? range.endDate : DateTime.now(),
      helpText: isStart
          ? 'Selecciona la fecha de inicio'
          : 'Selecciona la fecha de fin',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked == null) return;
    if (!context.mounted) return;

    applyReportDateSelection(
      context,
      ref.container,
      picked: picked,
      isStart: isStart,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(
      reportsDateRangeProvider.select(
        (r) => (startDate: r.startDate, endDate: r.endDate),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickDate(context, ref, isStart: true),
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(
              formatReportShortDate(range.startDate),
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
              formatReportShortDate(range.endDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => ref.read(reportsDateRangeProvider.notifier).reset(),
          tooltip: 'Restablecer al mes actual',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

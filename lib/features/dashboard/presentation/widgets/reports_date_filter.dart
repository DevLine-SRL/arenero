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

/// Selector de fechas compacto del panel: un solo icono (calendario) que abre
/// el menú de rango de fechas, en un contenedor con surface + outline.
class ReportsDateFilter extends ConsumerStatefulWidget {
  const ReportsDateFilter({super.key});

  @override
  ConsumerState<ReportsDateFilter> createState() => _ReportsDateFilterState();
}

class _ReportsDateFilterState extends ConsumerState<ReportsDateFilter> {
  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ref.watch(reportsDateRangeProvider);

    return SizedBox(
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: PopupMenuButton<String>(
          onSelected: (_) {},
          tooltip: 'Rango de fechas',
          itemBuilder: (menuContext) => [
            PopupMenuItem<String>(
              enabled: false,
              child: StatefulBuilder(
                builder: (context, setMenuState) {
                  final range = ref.read(reportsDateRangeProvider);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Rango de fechas',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _pickDate(context, isStart: true);
                          setMenuState(() {});
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Inicio ${formatReportShortDate(range.startDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _pickDate(context, isStart: false);
                          setMenuState(() {});
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Fin ${formatReportShortDate(range.endDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(reportsDateRangeProvider.notifier).reset();
                          setMenuState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Restablecer al mes actual'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          icon: Icon(
            Icons.calendar_today_rounded,
            size: 22,
            color: colorScheme.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
    );
  }
}

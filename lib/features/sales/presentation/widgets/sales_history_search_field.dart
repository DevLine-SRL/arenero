import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sales_history_date_range_provider.dart';
import '../providers/sales_history_search_query_provider.dart';
import '../utils/sale_formatters.dart';

class SalesHistorySearchField extends ConsumerStatefulWidget {
  static const debounce = Duration(milliseconds: 350);

  const SalesHistorySearchField({super.key});

  @override
  ConsumerState<SalesHistorySearchField> createState() =>
      _SalesHistorySearchFieldState();
}

class _SalesHistorySearchFieldState
    extends ConsumerState<SalesHistorySearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(SalesHistorySearchField.debounce, () {
      ref.read(salesHistorySearchQueryProvider.notifier).onTextChanged(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(salesHistorySearchQueryProvider.notifier).clear();
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final range = ref.read(salesHistoryDateRangeProvider);
    final now = DateTime.now();
    final initial = isStart ? (range.startDate ?? now) : (range.endDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null || !mounted) return;

    final start = isStart ? picked : range.startDate;
    final end = isStart ? range.endDate : picked;
    if (start != null && end != null && start.isAfter(end)) {
      if (!context.mounted) return;
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = ref.watch(
      salesHistorySearchQueryProvider.select((text) => text.isNotEmpty),
    );
    final range = ref.watch(salesHistoryDateRangeProvider);
    final filterActive = range.isActive;

    return SizedBox(
      height: 40,
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por cliente o cédula',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasText)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Limpiar búsqueda',
                  onPressed: _clear,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 0),
                  padding: const EdgeInsets.all(4),
                ),
              PopupMenuButton<String>(
                onSelected: (_) {},
                tooltip: 'Filtros',
                itemBuilder: (menuContext) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, setMenuState) {
                        final range = ref.read(salesHistoryDateRangeProvider);
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
                                range.startDate != null
                                    ? 'Inicio ${formatDate(range.startDate!)}'
                                    : 'Fecha inicio',
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
                                range.endDate != null
                                    ? 'Fin ${formatDate(range.endDate!)}'
                                    : 'Fecha fin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (range.isActive) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  ref
                                      .read(
                                        salesHistoryDateRangeProvider.notifier,
                                      )
                                      .clear();
                                  setMenuState(() {});
                                },
                                icon: const Icon(Icons.close_rounded, size: 18),
                                label: const Text('Quitar filtro'),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: filterActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 0),
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 0,
          ),
        ),
        textInputAction: TextInputAction.search,
        onChanged: _onChanged,
      ),
    );
  }
}

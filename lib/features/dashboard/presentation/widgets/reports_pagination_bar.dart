import 'package:flutter/material.dart';

class ReportsPaginationBar extends StatelessWidget {
  final int totalCount;
  final int page;
  final int pageSize;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ReportsPaginationBar({
    super.key,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPages = pageSize == 0 ? 0 : (totalCount / pageSize).ceil();
    final canGoPrevious = page > 0 && totalPages > 0;
    final canGoNext = totalPages > 0 && page + 1 < totalPages;
    final indicator = totalPages == 0 ? '0 / 0' : '${page + 1} / $totalPages';

    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(64, 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      visualDensity: VisualDensity.compact,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: buttonStyle,
                onPressed: canGoPrevious ? onPrevious : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Anterior'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(indicator, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                style: buttonStyle,
                onPressed: canGoNext ? onNext : null,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Siguiente'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ReportsColumn<T> {
  final String label;
  final String? sortKey;
  final double flex;

  const ReportsColumn({required this.label, this.sortKey, this.flex = 1});

  bool get sortable => sortKey != null;
}

class ReportsDataTable<T> extends StatelessWidget {
  final double minContentWidth;
  final List<ReportsColumn<T>> columns;
  final List<T> rows;
  final Widget Function(BuildContext context, T row, int columnIndex)
  cellBuilder;
  final String? sortColumn;
  final bool ascending;
  final ValueChanged<String> onSort;

  const ReportsDataTable({
    super.key,
    required this.minContentWidth,
    required this.columns,
    required this.rows,
    required this.cellBuilder,
    required this.sortColumn,
    required this.ascending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth < minContentWidth
            ? minContentWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: effectiveWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header<T>(
                    columns: columns,
                    sortColumn: sortColumn,
                    ascending: ascending,
                    onSort: onSort,
                  ),
                  const Divider(height: 1),
                  for (final row in rows)
                    _Row<T>(
                      columns: columns,
                      row: row,
                      cellBuilder: cellBuilder,
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

class _Header<T> extends StatelessWidget {
  final List<ReportsColumn<T>> columns;
  final String? sortColumn;
  final bool ascending;
  final ValueChanged<String> onSort;

  const _Header({
    required this.columns,
    required this.sortColumn,
    required this.ascending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Row(
      children: [
        for (final column in columns)
          Expanded(
            flex: column.flex.round(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: _SortableHeaderCell(
                label: column.label,
                active: sortColumn == column.sortKey,
                ascending: ascending,
                onTap: column.sortable && column.sortKey != null
                    ? () => onSort(column.sortKey!)
                    : null,
                textStyle: textStyle,
              ),
            ),
          ),
      ],
    );
  }
}

class _SortableHeaderCell extends StatelessWidget {
  final String label;
  final bool active;
  final bool ascending;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  const _SortableHeaderCell({
    required this.label,
    required this.active,
    required this.ascending,
    required this.onTap,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle?.copyWith(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : textStyle?.color,
            ),
          ),
        ),
        if (active) ...[
          const SizedBox(width: 4),
          Icon(
            ascending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: content,
    );
  }
}

class _Row<T> extends StatelessWidget {
  final List<ReportsColumn<T>> columns;
  final T row;
  final Widget Function(BuildContext context, T row, int columnIndex)
  cellBuilder;

  const _Row({
    required this.columns,
    required this.row,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < columns.length; i++)
          Expanded(
            flex: columns[i].flex.round(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: cellBuilder(context, row, i),
            ),
          ),
      ],
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_history_sort_provider.g.dart';

enum SalesHistorySortField { number, client, total }

enum SalesHistorySortDirection { ascending, descending }

class SalesHistorySortOption {
  final SalesHistorySortField field;
  final SalesHistorySortDirection direction;

  const SalesHistorySortOption({required this.field, required this.direction});
}

@riverpod
class SalesHistorySort extends _$SalesHistorySort {
  @override
  SalesHistorySortOption? build() => null;

  void toggle(SalesHistorySortField field) {
    final current = state;
    if (current != null && current.field == field) {
      state = SalesHistorySortOption(
        field: field,
        direction: current.direction == SalesHistorySortDirection.ascending
            ? SalesHistorySortDirection.descending
            : SalesHistorySortDirection.ascending,
      );
    } else {
      state = SalesHistorySortOption(
        field: field,
        direction: SalesHistorySortDirection.ascending,
      );
    }
  }
}

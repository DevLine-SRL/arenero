import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cobros_sort_provider.g.dart';

enum CobrosSortField { number, client, pendingAmount, saleDate }

enum CobrosSortDirection { ascending, descending }

class CobrosSortOption {
  final CobrosSortField field;
  final CobrosSortDirection direction;

  const CobrosSortOption({required this.field, required this.direction});
}

@riverpod
class CobrosSort extends _$CobrosSort {
  @override
  CobrosSortOption? build() => null;

  void toggle(CobrosSortField field) {
    final current = state;
    if (current != null && current.field == field) {
      state = CobrosSortOption(
        field: field,
        direction: current.direction == CobrosSortDirection.ascending
            ? CobrosSortDirection.descending
            : CobrosSortDirection.ascending,
      );
    } else {
      state = CobrosSortOption(
        field: field,
        direction: CobrosSortDirection.ascending,
      );
    }
  }
}

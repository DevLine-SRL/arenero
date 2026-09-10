import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cobros_selection_provider.g.dart';

@riverpod
class CobrosSelection extends _$CobrosSelection {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void toggleAll(List<String> ids) {
    if (state.length == ids.length && ids.every(state.contains)) {
      state = {};
    } else {
      state = {...ids};
    }
  }

  void clear() => state = {};

  bool isSelected(String id) => state.contains(id);

  bool isAllSelected(List<String> ids) =>
      ids.isNotEmpty && ids.every(state.contains);
}

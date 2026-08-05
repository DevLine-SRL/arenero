import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_history_search_query_provider.g.dart';

@riverpod
class SalesHistorySearchQuery extends _$SalesHistorySearchQuery {
  @override
  String build() => '';

  void onTextChanged(String text) => state = text;

  void clear() => state = '';
}

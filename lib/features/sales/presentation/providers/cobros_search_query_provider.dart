import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cobros_search_query_provider.g.dart';

@riverpod
class CobrosSearchQuery extends _$CobrosSearchQuery {
  @override
  String build() => '';

  void onTextChanged(String text) => state = text;

  void clear() => state = '';
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_search_query_provider.g.dart';

/// Texto de búsqueda de productos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.
@riverpod
class ProductsSearchQuery extends _$ProductsSearchQuery {
  @override
  String build() => '';

  void onTextChanged(String text) => state = text;

  void clear() => state = '';
}

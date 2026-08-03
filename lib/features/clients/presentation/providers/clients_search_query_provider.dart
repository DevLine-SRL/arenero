import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clients_search_query_provider.g.dart';

/// Texto de búsqueda y filtro de inactivos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.
@riverpod
class ClientsSearchQuery extends _$ClientsSearchQuery {
  @override
  ClientsQuery build() => const ClientsQuery();

  void onTextChanged(String text) {
    state = ClientsQuery(text: text, includeInactive: state.includeInactive);
  }

  void onIncludeInactiveChanged(bool includeInactive) {
    state = ClientsQuery(text: state.text, includeInactive: includeInactive);
  }

  void clear() => state = ClientsQuery(includeInactive: state.includeInactive);
}

class ClientsQuery {
  final String text;
  final bool includeInactive;

  const ClientsQuery({this.text = '', this.includeInactive = false});

  @override
  bool operator ==(Object other) {
    return other is ClientsQuery &&
        other.text == text &&
        other.includeInactive == includeInactive;
  }

  @override
  int get hashCode => Object.hash(text, includeInactive);
}

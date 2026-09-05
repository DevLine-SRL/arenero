import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../widgets/client_status_filter.dart';

part 'clients_search_query_provider.g.dart';

/// Texto de búsqueda y filtro de estado. `active` por defecto: coincide con el
/// comportamiento previo (`includeInactive: false`).
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.
@riverpod
class ClientsSearchQuery extends _$ClientsSearchQuery {
  @override
  ClientsQuery build() => const ClientsQuery();

  void onTextChanged(String text) {
    state = ClientsQuery(text: text, status: state.status);
  }

  void onStatusChanged(ClientStatusFilter status) {
    state = ClientsQuery(text: state.text, status: status);
  }

  void clear() => state = ClientsQuery(status: state.status);
}

class ClientsQuery {
  final String text;
  final ClientStatusFilter status;

  const ClientsQuery({this.text = '', this.status = ClientStatusFilter.active});

  @override
  bool operator ==(Object other) {
    return other is ClientsQuery &&
        other.text == text &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(text, status);
}

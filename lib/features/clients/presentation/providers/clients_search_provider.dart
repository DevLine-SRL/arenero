import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/is_online_provider.dart';
import '../../domain/entities/client.dart';
import 'clients_providers.dart';
import 'clients_search_query_provider.dart';

part 'clients_search_provider.g.dart';

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa, así que también es la fuente de la pantalla al abrirla.
@riverpod
class ClientsSearch extends _$ClientsSearch {
  bool _refreshInFlight = false;

  @override
  Future<List<Client>> build() async {
    final query = ref.watch(clientsSearchQueryProvider);
    ref.watch(searchClientsUseCaseProvider);
    ref.watch(searchCachedClientsUseCaseProvider);

    final cachedResult = await ref.read(searchCachedClientsUseCaseProvider)(
      query: query.text,
      includeInactive: query.includeInactive,
    );
    final cached = cachedResult.fold((_) => null, (clients) => clients);
    if (cached != null) {
      _refreshInBackground(query);
      return cached;
    }

    final remote = await ref.read(searchClientsUseCaseProvider)(
      query: query.text,
      includeInactive: query.includeInactive,
    );
    return remote.fold((failure) => throw failure, (clients) => clients);
  }

  Future<void> _refreshInBackground(ClientsQuery query) async {
    if (_refreshInFlight) return;
    if (!ref.read(isOnlineProvider)) return;
    _refreshInFlight = true;
    try {
      final result = await ref.read(searchClientsUseCaseProvider)(
        query: query.text,
        includeInactive: query.includeInactive,
      );
      if (!ref.mounted) return;
      result.fold((_) {}, (clients) {
        final current = ref.read(clientsSearchQueryProvider);
        if (current.text != query.text ||
            current.includeInactive != query.includeInactive) {
          return;
        }
        state = AsyncData(clients);
      });
    } finally {
      _refreshInFlight = false;
    }
  }
}

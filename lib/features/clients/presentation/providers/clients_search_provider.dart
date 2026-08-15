import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/datasources/sync_local_datasource.dart';
import '../../../../core/models/sync_status.dart';
import '../../../../core/providers/is_online_provider.dart';
import '../../../../core/providers/sync_local_datasource_provider.dart';
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
      result.fold((_) {}, (clients) async {
        final current = ref.read(clientsSearchQueryProvider);
        if (current.text != query.text ||
            current.includeInactive != query.includeInactive) {
          return;
        }
        final merged = await _mergeWithPending(clients, query);
        if (!ref.mounted) return;
        state = AsyncData(merged);
      });
    } finally {
      _refreshInFlight = false;
    }
  }

  Future<List<Client>> _mergeWithPending(
    List<Client> clients,
    ClientsQuery query,
  ) async {
    final sync = ref.read(syncLocalDataSourceProvider);
    final pending = await sync.getPendingOperations();
    final failed = await sync.getFailedOperations();

    final localClients = <Client>[
      for (final operation in pending)
        if (operation.operation == OutboxOperationType.createClient)
          _pendingClient(operation, status: SyncStatus.pending),
      for (final operation in failed)
        if (operation.operation == OutboxOperationType.createClient)
          _pendingClient(operation, status: SyncStatus.error),
    ].where((client) => _matchesQuery(client, query)).toList();
    if (localClients.isEmpty) return clients;

    final mergedIds = {for (final client in localClients) client.id};
    return [
      ...localClients,
      for (final client in clients)
        if (!mergedIds.contains(client.id)) client,
    ];
  }

  Client _pendingClient(
    PendingOperation operation, {
    required SyncStatus status,
  }) {
    final payload = operation.payload;
    return Client(
      id: payload['id'] as String,
      name: payload['name'] as String,
      phone: payload['phone'] as String?,
      ci: payload['ci'] as String,
      nit: payload['nit'] as String?,
      active: true,
      syncStatus: status,
    );
  }

  bool _matchesQuery(Client client, ClientsQuery query) {
    if (!query.includeInactive && !client.active) return false;
    final term = query.text.trim().toLowerCase();
    if (term.isEmpty) return true;
    return client.name.toLowerCase().contains(term) ||
        client.ci.toLowerCase().contains(term) ||
        (client.nit?.toLowerCase().contains(term) ?? false);
  }
}

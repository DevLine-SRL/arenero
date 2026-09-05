import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/client.dart';
import '../widgets/client_status_filter.dart';
import 'clients_providers.dart';
import 'clients_search_query_provider.dart';

part 'clients_search_provider.g.dart';

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa del estado seleccionado, así que también es la fuente de la
/// pantalla al abrirla.
///
/// `active` y `all` se resuelven en la base (`includeInactive` true/false); el
/// caso `inactive` pide la lista completa y descarta los activos en memoria
/// porque la base no filtra solo inactivos.
@riverpod
class ClientsSearch extends _$ClientsSearch {
  @override
  Future<List<Client>> build() async {
    final query = ref.watch(clientsSearchQueryProvider);
    final useCase = ref.watch(searchClientsUseCaseProvider);

    final result = await useCase(
      query: query.text,
      includeInactive: query.status != ClientStatusFilter.active,
    );

    return result.fold(
      (failure) => throw failure,
      (clients) => query.status == ClientStatusFilter.inactive
          ? clients.where((client) => !client.active).toList()
          : clients,
    );
  }
}

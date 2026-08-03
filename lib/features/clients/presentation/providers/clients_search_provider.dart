import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/client.dart';
import 'clients_providers.dart';
import 'clients_search_query_provider.dart';

part 'clients_search_provider.g.dart';

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa, así que también es la fuente de la pantalla al abrirla.
@riverpod
class ClientsSearch extends _$ClientsSearch {
  @override
  Future<List<Client>> build() async {
    final query = ref.watch(clientsSearchQueryProvider);
    final useCase = ref.watch(searchClientsUseCaseProvider);

    final result = await useCase(
      query: query.text,
      includeInactive: query.includeInactive,
    );

    return result.fold((failure) => throw failure, (clients) => clients);
  }
}

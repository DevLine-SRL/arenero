import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/client.dart';
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

    // Devuelve todos los clientes que coinciden con el texto, activos e
    // inactivos. El filtro por estado y los contadores son responsabilidad de
    // la página, igual que en la gestión de vendedores.
    final result = await useCase(query: query.text, includeInactive: true);

    return result.fold((failure) => throw failure, (clients) => clients);
  }

  /// Desactiva o reactiva varios clientes a la vez y vuelve a consultar para
  /// que la lista refleje el filtro seleccionado.
  Future<void> setActive(Set<String> ids, bool active) async {
    if (ids.isEmpty) return;

    final useCase = ref.read(setClientsActiveUseCaseProvider);
    for (final id in ids) {
      await useCase(id: id, active: active);
    }
    ref.invalidateSelf();
  }

  /// Edita un cliente y, si guarda bien, devuelve `null`. Si falla, devuelve
  /// el [Failure] para mostrarlo en el diálogo sin cerrarlo.
  Future<Failure?> updateClient(
    Client client, {
    required String name,
    required String ci,
    String? phone,
    String? nit,
  }) async {
    final result = await ref.read(updateClientUseCaseProvider)(
      id: client.id,
      name: name,
      rawCi: ci,
      phone: phone,
      nit: nit,
    );

    return result.fold((failure) => failure, (_) {
      ref.invalidateSelf();
      return null;
    });
  }
}

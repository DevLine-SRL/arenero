import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/client.dart';
import 'clients_providers.dart';

part 'clients_search_provider.g.dart';

/// Lista completa de clientes (activos e inactivos), cargada una sola vez.
///
/// El texto de búsqueda y el filtro de estado se aplican en memoria en la
/// página, igual que en la gestión de productos y vendedores, para que
/// escribir o cambiar el filtro no vuelva a golpear la base de datos.
@riverpod
class ClientsSearch extends _$ClientsSearch {
  @override
  Future<List<Client>> build() async {
    final useCase = ref.watch(searchClientsUseCaseProvider);

    final result = await useCase(query: '', includeInactive: true);

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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/providers/clients_providers.dart';

part 'clients_picker_provider.g.dart';

/// Resultados de la búsqueda de clientes dentro del selector de venta.
///
/// Independiente de [clientsSearchProvider] para no tocar el texto de búsqueda
/// compartido con la pantalla de clientes.
@riverpod
Future<List<Client>> clientsPickerResults(Ref ref, String query) async {
  final useCase = ref.watch(searchClientsUseCaseProvider);
  final result = await useCase(query: query.trim(), includeInactive: false);
  return result.fold((failure) => throw failure, (clients) => clients);
}

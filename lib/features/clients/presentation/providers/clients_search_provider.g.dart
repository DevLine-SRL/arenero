// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa, así que también es la fuente de la pantalla al abrirla.

@ProviderFor(ClientsSearch)
final clientsSearchProvider = ClientsSearchProvider._();

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa, así que también es la fuente de la pantalla al abrirla.
final class ClientsSearchProvider
    extends $AsyncNotifierProvider<ClientsSearch, List<Client>> {
  /// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
  /// completa, así que también es la fuente de la pantalla al abrirla.
  ClientsSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsSearchHash();

  @$internal
  @override
  ClientsSearch create() => ClientsSearch();
}

String _$clientsSearchHash() => r'9b23c52488fe86ea0c2f9ad0910237103e939aab';

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa, así que también es la fuente de la pantalla al abrirla.

abstract class _$ClientsSearch extends $AsyncNotifier<List<Client>> {
  FutureOr<List<Client>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Client>>, List<Client>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Client>>, List<Client>>,
              AsyncValue<List<Client>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

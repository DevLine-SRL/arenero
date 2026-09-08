// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lista completa de clientes (activos e inactivos), cargada una sola vez.
///
/// El texto de búsqueda y el filtro de estado se aplican en memoria en la
/// página, igual que en la gestión de productos y vendedores, para que
/// escribir o cambiar el filtro no vuelva a golpear la base de datos.

@ProviderFor(ClientsSearch)
final clientsSearchProvider = ClientsSearchProvider._();

/// Lista completa de clientes (activos e inactivos), cargada una sola vez.
///
/// El texto de búsqueda y el filtro de estado se aplican en memoria en la
/// página, igual que en la gestión de productos y vendedores, para que
/// escribir o cambiar el filtro no vuelva a golpear la base de datos.
final class ClientsSearchProvider
    extends $AsyncNotifierProvider<ClientsSearch, List<Client>> {
  /// Lista completa de clientes (activos e inactivos), cargada una sola vez.
  ///
  /// El texto de búsqueda y el filtro de estado se aplican en memoria en la
  /// página, igual que en la gestión de productos y vendedores, para que
  /// escribir o cambiar el filtro no vuelva a golpear la base de datos.
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

String _$clientsSearchHash() => r'932c0e8b56ed61329053d1889297d60a096ce7a3';

/// Lista completa de clientes (activos e inactivos), cargada una sola vez.
///
/// El texto de búsqueda y el filtro de estado se aplican en memoria en la
/// página, igual que en la gestión de productos y vendedores, para que
/// escribir o cambiar el filtro no vuelva a golpear la base de datos.

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

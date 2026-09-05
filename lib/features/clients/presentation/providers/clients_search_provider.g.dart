// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa del estado seleccionado, así que también es la fuente de la
/// pantalla al abrirla.
///
/// `active` y `all` se resuelven en la base (`includeInactive` true/false); el
/// caso `inactive` pide la lista completa y descarta los activos en memoria
/// porque la base no filtra solo inactivos.

@ProviderFor(ClientsSearch)
final clientsSearchProvider = ClientsSearchProvider._();

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa del estado seleccionado, así que también es la fuente de la
/// pantalla al abrirla.
///
/// `active` y `all` se resuelven en la base (`includeInactive` true/false); el
/// caso `inactive` pide la lista completa y descarta los activos en memoria
/// porque la base no filtra solo inactivos.
final class ClientsSearchProvider
    extends $AsyncNotifierProvider<ClientsSearch, List<Client>> {
  /// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
  /// completa del estado seleccionado, así que también es la fuente de la
  /// pantalla al abrirla.
  ///
  /// `active` y `all` se resuelven en la base (`includeInactive` true/false); el
  /// caso `inactive` pide la lista completa y descarta los activos en memoria
  /// porque la base no filtra solo inactivos.
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

String _$clientsSearchHash() => r'eadc17470a285e502fba4119f11bda9912a515fc';

/// Resultado de la consulta de clientes. Con el texto vacío devuelve la lista
/// completa del estado seleccionado, así que también es la fuente de la
/// pantalla al abrirla.
///
/// `active` y `all` se resuelven en la base (`includeInactive` true/false); el
/// caso `inactive` pide la lista completa y descarta los activos en memoria
/// porque la base no filtra solo inactivos.

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

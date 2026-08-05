// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_search_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Texto de búsqueda y filtro de inactivos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.

@ProviderFor(ClientsSearchQuery)
final clientsSearchQueryProvider = ClientsSearchQueryProvider._();

/// Texto de búsqueda y filtro de inactivos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.
final class ClientsSearchQueryProvider
    extends $NotifierProvider<ClientsSearchQuery, ClientsQuery> {
  /// Texto de búsqueda y filtro de inactivos. Vacío significa "todos".
  ///
  /// El rebote del teclado lo hace el campo de texto, no este provider, para que
  /// siga siendo puro y fácil de probar.
  ClientsSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsSearchQueryHash();

  @$internal
  @override
  ClientsSearchQuery create() => ClientsSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsQuery>(value),
    );
  }
}

String _$clientsSearchQueryHash() =>
    r'8d54b571f4eedb3e2e368a0b5c8039a6e49df07d';

/// Texto de búsqueda y filtro de inactivos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.

abstract class _$ClientsSearchQuery extends $Notifier<ClientsQuery> {
  ClientsQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ClientsQuery, ClientsQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientsQuery, ClientsQuery>,
              ClientsQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

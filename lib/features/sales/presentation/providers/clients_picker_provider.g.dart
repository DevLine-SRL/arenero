// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_picker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resultados de la búsqueda de clientes dentro del selector de venta.
///
/// Independiente de [clientsSearchProvider] para no tocar el texto de búsqueda
/// compartido con la pantalla de clientes.

@ProviderFor(clientsPickerResults)
final clientsPickerResultsProvider = ClientsPickerResultsFamily._();

/// Resultados de la búsqueda de clientes dentro del selector de venta.
///
/// Independiente de [clientsSearchProvider] para no tocar el texto de búsqueda
/// compartido con la pantalla de clientes.

final class ClientsPickerResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Client>>,
          List<Client>,
          FutureOr<List<Client>>
        >
    with $FutureModifier<List<Client>>, $FutureProvider<List<Client>> {
  /// Resultados de la búsqueda de clientes dentro del selector de venta.
  ///
  /// Independiente de [clientsSearchProvider] para no tocar el texto de búsqueda
  /// compartido con la pantalla de clientes.
  ClientsPickerResultsProvider._({
    required ClientsPickerResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientsPickerResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientsPickerResultsHash();

  @override
  String toString() {
    return r'clientsPickerResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Client>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Client>> create(Ref ref) {
    final argument = this.argument as String;
    return clientsPickerResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientsPickerResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientsPickerResultsHash() =>
    r'4ff4edc9c96d8c8230040b17bf7c2e652fab8a27';

/// Resultados de la búsqueda de clientes dentro del selector de venta.
///
/// Independiente de [clientsSearchProvider] para no tocar el texto de búsqueda
/// compartido con la pantalla de clientes.

final class ClientsPickerResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Client>>, String> {
  ClientsPickerResultsFamily._()
    : super(
        retry: null,
        name: r'clientsPickerResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resultados de la búsqueda de clientes dentro del selector de venta.
  ///
  /// Independiente de [clientsSearchProvider] para no tocar el texto de búsqueda
  /// compartido con la pantalla de clientes.

  ClientsPickerResultsProvider call(String query) =>
      ClientsPickerResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'clientsPickerResultsProvider';
}

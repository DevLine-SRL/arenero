// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_mock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fuente provisional de ventas del historial (datos mockeados).
///
/// Se reemplazará por el repositorio real cuando se conecte al backend.

@ProviderFor(salesHistoryMockData)
final salesHistoryMockDataProvider = SalesHistoryMockDataProvider._();

/// Fuente provisional de ventas del historial (datos mockeados).
///
/// Se reemplazará por el repositorio real cuando se conecte al backend.

final class SalesHistoryMockDataProvider
    extends $FunctionalProvider<List<Sale>, List<Sale>, List<Sale>>
    with $Provider<List<Sale>> {
  /// Fuente provisional de ventas del historial (datos mockeados).
  ///
  /// Se reemplazará por el repositorio real cuando se conecte al backend.
  SalesHistoryMockDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesHistoryMockDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistoryMockDataHash();

  @$internal
  @override
  $ProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Sale> create(Ref ref) {
    return salesHistoryMockData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Sale> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Sale>>(value),
    );
  }
}

String _$salesHistoryMockDataHash() =>
    r'3cd9cb66fcb79275ec759e8339acea975a912554';

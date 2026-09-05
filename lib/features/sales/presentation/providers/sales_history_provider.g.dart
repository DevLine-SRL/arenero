// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(salesHistoryData)
final salesHistoryDataProvider = SalesHistoryDataProvider._();

final class SalesHistoryDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SaleHistoryItem>>,
          List<SaleHistoryItem>,
          FutureOr<List<SaleHistoryItem>>
        >
    with
        $FutureModifier<List<SaleHistoryItem>>,
        $FutureProvider<List<SaleHistoryItem>> {
  SalesHistoryDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesHistoryDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistoryDataHash();

  @$internal
  @override
  $FutureProviderElement<List<SaleHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SaleHistoryItem>> create(Ref ref) {
    return salesHistoryData(ref);
  }
}

String _$salesHistoryDataHash() => r'9cdf2497f4cc9b574816172a21aef693c803ab3a';

@ProviderFor(salesHistory)
final salesHistoryProvider = SalesHistoryProvider._();

final class SalesHistoryProvider
    extends
        $FunctionalProvider<
          List<SaleHistoryItem>,
          List<SaleHistoryItem>,
          List<SaleHistoryItem>
        >
    with $Provider<List<SaleHistoryItem>> {
  SalesHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesHistoryHash();

  @$internal
  @override
  $ProviderElement<List<SaleHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SaleHistoryItem> create(Ref ref) {
    return salesHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SaleHistoryItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SaleHistoryItem>>(value),
    );
  }
}

String _$salesHistoryHash() => r'4fd55f2b81ec995fc485cc1698cbd1afac839ff5';

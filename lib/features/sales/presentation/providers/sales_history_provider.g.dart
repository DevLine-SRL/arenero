// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(salesHistory)
final salesHistoryProvider = SalesHistoryProvider._();

final class SalesHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SaleHistoryItem>>,
          List<SaleHistoryItem>,
          FutureOr<List<SaleHistoryItem>>
        >
    with
        $FutureModifier<List<SaleHistoryItem>>,
        $FutureProvider<List<SaleHistoryItem>> {
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
  $FutureProviderElement<List<SaleHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SaleHistoryItem>> create(Ref ref) {
    return salesHistory(ref);
  }
}

String _$salesHistoryHash() => r'13e6592c55775dbf953356f00ccc88034733b9c4';

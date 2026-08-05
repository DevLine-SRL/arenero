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
    extends $FunctionalProvider<List<Sale>, List<Sale>, List<Sale>>
    with $Provider<List<Sale>> {
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
  $ProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Sale> create(Ref ref) {
    return salesHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Sale> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Sale>>(value),
    );
  }
}

String _$salesHistoryHash() => r'3e0c9423b7022474b05429d1b96762e858e62089';

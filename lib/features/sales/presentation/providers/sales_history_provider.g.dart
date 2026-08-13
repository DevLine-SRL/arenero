// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SalesHistory)
final salesHistoryProvider = SalesHistoryProvider._();

final class SalesHistoryProvider
    extends $AsyncNotifierProvider<SalesHistory, List<SaleHistoryItem>> {
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
  SalesHistory create() => SalesHistory();
}

String _$salesHistoryHash() => r'a35dbcb05971036628a080f499f44a310d46641e';

abstract class _$SalesHistory extends $AsyncNotifier<List<SaleHistoryItem>> {
  FutureOr<List<SaleHistoryItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<SaleHistoryItem>>, List<SaleHistoryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SaleHistoryItem>>,
                List<SaleHistoryItem>
              >,
              AsyncValue<List<SaleHistoryItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

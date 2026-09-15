// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pendingSalesData)
final pendingSalesDataProvider = PendingSalesDataProvider._();

final class PendingSalesDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  PendingSalesDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSalesDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSalesDataHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return pendingSalesData(ref);
  }
}

String _$pendingSalesDataHash() => r'225543ebeabed1e64a2cb850873690f2ac5da1b4';

@ProviderFor(pendingSales)
final pendingSalesProvider = PendingSalesProvider._();

final class PendingSalesProvider
    extends $FunctionalProvider<List<Sale>, List<Sale>, List<Sale>>
    with $Provider<List<Sale>> {
  PendingSalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSalesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSalesHash();

  @$internal
  @override
  $ProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Sale> create(Ref ref) {
    return pendingSales(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Sale> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Sale>>(value),
    );
  }
}

String _$pendingSalesHash() => r'fb533a40e1933b3b635bec8db29ddeb6f4808edf';

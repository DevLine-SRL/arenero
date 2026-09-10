// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductsSelection)
final productsSelectionProvider = ProductsSelectionProvider._();

final class ProductsSelectionProvider
    extends $NotifierProvider<ProductsSelection, Set<String>> {
  ProductsSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsSelectionHash();

  @$internal
  @override
  ProductsSelection create() => ProductsSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$productsSelectionHash() => r'33f4afa5f79d10f27cedf577b7162e1bcc92bc22';

abstract class _$ProductsSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

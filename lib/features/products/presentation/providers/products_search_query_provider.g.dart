// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_search_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Texto de búsqueda de productos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.

@ProviderFor(ProductsSearchQuery)
final productsSearchQueryProvider = ProductsSearchQueryProvider._();

/// Texto de búsqueda de productos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.
final class ProductsSearchQueryProvider
    extends $NotifierProvider<ProductsSearchQuery, String> {
  /// Texto de búsqueda de productos. Vacío significa "todos".
  ///
  /// El rebote del teclado lo hace el campo de texto, no este provider, para que
  /// siga siendo puro y fácil de probar.
  ProductsSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsSearchQueryHash();

  @$internal
  @override
  ProductsSearchQuery create() => ProductsSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$productsSearchQueryHash() =>
    r'10754cfc0a5ab2c39e7b5e8fc4030a87eb7e9114';

/// Texto de búsqueda de productos. Vacío significa "todos".
///
/// El rebote del teclado lo hace el campo de texto, no este provider, para que
/// siga siendo puro y fácil de probar.

abstract class _$ProductsSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

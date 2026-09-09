// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cobros_search_query_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CobrosSearchQuery)
final cobrosSearchQueryProvider = CobrosSearchQueryProvider._();

final class CobrosSearchQueryProvider
    extends $NotifierProvider<CobrosSearchQuery, String> {
  CobrosSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cobrosSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cobrosSearchQueryHash();

  @$internal
  @override
  CobrosSearchQuery create() => CobrosSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$cobrosSearchQueryHash() => r'ea5e8d23c69d9c69df802b2ce99c6de8df49da89';

abstract class _$CobrosSearchQuery extends $Notifier<String> {
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

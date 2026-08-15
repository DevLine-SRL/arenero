// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pendingSales)
final pendingSalesProvider = PendingSalesProvider._();

final class PendingSalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
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
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return pendingSales(ref);
  }
}

String _$pendingSalesHash() => r'61769c6ac714fa26e96c52b34b4d60d6a38a785b';

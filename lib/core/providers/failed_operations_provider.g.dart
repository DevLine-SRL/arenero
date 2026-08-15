// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failed_operations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(failedOperationsCount)
final failedOperationsCountProvider = FailedOperationsCountProvider._();

final class FailedOperationsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  FailedOperationsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'failedOperationsCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$failedOperationsCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return failedOperationsCount(ref);
  }
}

String _$failedOperationsCountHash() =>
    r'10c15a797ccb177e7ff0d91c102b15d371b9c2db';

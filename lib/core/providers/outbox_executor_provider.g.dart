// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_executor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(outboxExecutor)
final outboxExecutorProvider = OutboxExecutorProvider._();

final class OutboxExecutorProvider
    extends $FunctionalProvider<OutboxExecutor, OutboxExecutor, OutboxExecutor>
    with $Provider<OutboxExecutor> {
  OutboxExecutorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxExecutorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxExecutorHash();

  @$internal
  @override
  $ProviderElement<OutboxExecutor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxExecutor create(Ref ref) {
    return outboxExecutor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxExecutor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxExecutor>(value),
    );
  }
}

String _$outboxExecutorHash() => r'6dbff404afa880415f0878ec22f48d438b475c21';

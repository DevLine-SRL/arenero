// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_timeout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SessionTimeoutController)
final sessionTimeoutControllerProvider = SessionTimeoutControllerProvider._();

final class SessionTimeoutControllerProvider
    extends $NotifierProvider<SessionTimeoutController, void> {
  SessionTimeoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionTimeoutControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionTimeoutControllerHash();

  @$internal
  @override
  SessionTimeoutController create() => SessionTimeoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sessionTimeoutControllerHash() =>
    r'df62a0c99f89544f5bf17e9785a8312f617222e2';

abstract class _$SessionTimeoutController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

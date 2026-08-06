// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_recovery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PasswordRecovery)
final passwordRecoveryProvider = PasswordRecoveryProvider._();

final class PasswordRecoveryProvider
    extends $NotifierProvider<PasswordRecovery, PasswordRecoveryState> {
  PasswordRecoveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordRecoveryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordRecoveryHash();

  @$internal
  @override
  PasswordRecovery create() => PasswordRecovery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordRecoveryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordRecoveryState>(value),
    );
  }
}

String _$passwordRecoveryHash() => r'8db78c0f95a73c993e91cb1601c1cddd8b49e2e0';

abstract class _$PasswordRecovery extends $Notifier<PasswordRecoveryState> {
  PasswordRecoveryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PasswordRecoveryState, PasswordRecoveryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PasswordRecoveryState, PasswordRecoveryState>,
              PasswordRecoveryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

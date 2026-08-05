// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_seen_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mantiene viva la sesión por cuenta: registra la última actividad del
/// usuario en `profiles.last_seen_at` y, al abrir la app, cierra la sesión si
/// lleva más de `AppConfig.sessionMaxAbsence` sin entrar. Así el timer de
/// inactividad (`SessionTimeoutController`) cubre la sesión abierta, y este
/// provider cubre la ausencia prolongada entre aperturas.

@ProviderFor(LastSeenSync)
final lastSeenSyncProvider = LastSeenSyncProvider._();

/// Mantiene viva la sesión por cuenta: registra la última actividad del
/// usuario en `profiles.last_seen_at` y, al abrir la app, cierra la sesión si
/// lleva más de `AppConfig.sessionMaxAbsence` sin entrar. Así el timer de
/// inactividad (`SessionTimeoutController`) cubre la sesión abierta, y este
/// provider cubre la ausencia prolongada entre aperturas.
final class LastSeenSyncProvider extends $NotifierProvider<LastSeenSync, void> {
  /// Mantiene viva la sesión por cuenta: registra la última actividad del
  /// usuario en `profiles.last_seen_at` y, al abrir la app, cierra la sesión si
  /// lleva más de `AppConfig.sessionMaxAbsence` sin entrar. Así el timer de
  /// inactividad (`SessionTimeoutController`) cubre la sesión abierta, y este
  /// provider cubre la ausencia prolongada entre aperturas.
  LastSeenSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastSeenSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastSeenSyncHash();

  @$internal
  @override
  LastSeenSync create() => LastSeenSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$lastSeenSyncHash() => r'1658479d90d16689afee2adc847408146a67bb0c';

/// Mantiene viva la sesión por cuenta: registra la última actividad del
/// usuario en `profiles.last_seen_at` y, al abrir la app, cierra la sesión si
/// lleva más de `AppConfig.sessionMaxAbsence` sin entrar. Así el timer de
/// inactividad (`SessionTimeoutController`) cubre la sesión abierta, y este
/// provider cubre la ausencia prolongada entre aperturas.

abstract class _$LastSeenSync extends $Notifier<void> {
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

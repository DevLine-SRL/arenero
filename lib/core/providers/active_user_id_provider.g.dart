// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_user_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Usuario con sesión activa. `null` si nadie inició sesión. Las datasources
/// locales lo usan para aislar la caché y el outbox por usuario.

@ProviderFor(activeUserId)
final activeUserIdProvider = ActiveUserIdProvider._();

/// Usuario con sesión activa. `null` si nadie inició sesión. Las datasources
/// locales lo usan para aislar la caché y el outbox por usuario.

final class ActiveUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Usuario con sesión activa. `null` si nadie inició sesión. Las datasources
  /// locales lo usan para aislar la caché y el outbox por usuario.
  ActiveUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return activeUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeUserIdHash() => r'19cc23b92fb09a15dd80e7d73937bb212b62d370';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientsSelection)
final clientsSelectionProvider = ClientsSelectionProvider._();

final class ClientsSelectionProvider
    extends $NotifierProvider<ClientsSelection, Set<String>> {
  ClientsSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsSelectionHash();

  @$internal
  @override
  ClientsSelection create() => ClientsSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$clientsSelectionHash() => r'3a5cd9701c77c00df714289365ceecc9e652a19a';

abstract class _$ClientsSelection extends $Notifier<Set<String>> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_client_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectedClientReport)
final selectedClientReportProvider = SelectedClientReportFamily._();

final class SelectedClientReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClientReportRow?>,
          ClientReportRow?,
          FutureOr<ClientReportRow?>
        >
    with $FutureModifier<ClientReportRow?>, $FutureProvider<ClientReportRow?> {
  SelectedClientReportProvider._({
    required SelectedClientReportFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'selectedClientReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedClientReportHash();

  @override
  String toString() {
    return r'selectedClientReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClientReportRow?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClientReportRow?> create(Ref ref) {
    final argument = this.argument as String?;
    return selectedClientReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedClientReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedClientReportHash() =>
    r'3a71a136a44c55de377492a73f563fdbe879566f';

final class SelectedClientReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClientReportRow?>, String?> {
  SelectedClientReportFamily._()
    : super(
        retry: null,
        name: r'selectedClientReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SelectedClientReportProvider call(String? clientId) =>
      SelectedClientReportProvider._(argument: clientId, from: this);

  @override
  String toString() => r'selectedClientReportProvider';
}

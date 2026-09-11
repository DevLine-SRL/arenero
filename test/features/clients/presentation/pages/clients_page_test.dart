import 'package:arenero/features/clients/presentation/pages/clients_page.dart';
import 'package:arenero/features/clients/presentation/providers/clients_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/builders/client_builder.dart';
import '../../../../support/fakes/fake_clients_repository.dart';

void main() {
  group('ClientsPage', () {
    testWidgets('shows active clients by default with their badges', (
      tester,
    ) async {
      final repository = FakeClientsRepository();
      repository.searchResult = Right([
        buildClient(id: '1', name: 'Juan Pérez'),
        buildClient(id: '2', name: 'Ana López', active: false),
      ]);
      await _pumpPage(tester, repository);

      expect(find.text('Gestión de Clientes'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.byTooltip('Activo'), findsOneWidget);
      // La vista por defecto es la de activos, así que Ana (inactiva) no se ve.
      expect(find.text('Ana López'), findsNothing);
    });

    testWidgets('does not disable when confirmation is cancelled', (
      tester,
    ) async {
      final repository = FakeClientsRepository();
      repository.searchResult = Right([
        buildClient(id: '1', name: 'Juan Pérez'),
      ]);
      await _pumpPage(tester, repository);

      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deshabilitar'));
      await tester.pumpAndSettle();

      expect(find.text('Deshabilitar clientes'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 0);
    });

    testWidgets('disables a selected client after confirmation', (
      tester,
    ) async {
      final repository = FakeClientsRepository();
      repository.searchResult = Right([
        buildClient(id: '1', name: 'Juan Pérez'),
      ]);
      await _pumpPage(tester, repository);

      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deshabilitar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Si, deshabilitar'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 1);
    });

    testWidgets('shows the edit dialog and saves the changes', (tester) async {
      final repository = FakeClientsRepository();
      repository.searchResult = Right([
        buildClient(id: '1', name: 'Juan Pérez'),
      ]);
      await _pumpPage(tester, repository);

      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Editar cliente'), findsOneWidget);

      final nameField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField.first, 'Juan Carlos');
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(repository.lastUpdatedId, '1');
      expect(repository.lastUpdatedName, 'Juan Carlos');
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  FakeClientsRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [clientsRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: Scaffold(body: ClientsPage())),
    ),
  );
  await tester.pumpAndSettle();
}

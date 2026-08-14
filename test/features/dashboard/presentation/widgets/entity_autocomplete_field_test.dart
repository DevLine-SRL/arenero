import 'dart:async';

import 'package:arenero/features/reports/domain/entities/report_suggestion.dart';
import 'package:arenero/features/dashboard/presentation/widgets/entity_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const suggestions = [
  ReportSuggestion(id: 'client-1', name: 'Juan Pérez'),
  ReportSuggestion(id: 'client-2', name: 'Juana Martínez'),
  ReportSuggestion(id: 'client-3', name: 'José López'),
];

void main() {
  group('EntityAutocompleteField', () {
    testWidgets('shows matching suggestions after the debounce', (
      tester,
    ) async {
      ReportSuggestion? selected;
      await _pump(tester, onSelected: (s) => selected = s);

      await tester.enterText(find.byType(TextField), 'Ju');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Juana Martínez'), findsOneWidget);

      await tester.tap(find.text('Juana Martínez'));
      await tester.pump();

      expect(selected?.id, 'client-2');
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('waits for the debounce before querying', (tester) async {
      var callCount = 0;
      await _pump(
        tester,
        loadSuggestions: (ref, query) async {
          callCount++;
          return suggestions;
        },
      );

      await tester.enterText(find.byType(TextField), 'J');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'Ju');
      await tester.pump(const Duration(milliseconds: 100));

      expect(callCount, 1);

      await tester.pump(const Duration(milliseconds: 250));

      expect(callCount, 2);
    });

    testWidgets('shows initial suggestions when focused without typing', (
      tester,
    ) async {
      final queried = <String>[];
      await _pump(
        tester,
        loadSuggestions: (ref, query) async {
          queried.add(query);
          return suggestions;
        },
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(queried, contains(''));
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Juana Martínez'), findsOneWidget);
      expect(find.text('José López'), findsOneWidget);
    });

    testWidgets('dismisses suggestions when tapping outside the field', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsOneWidget);

      await tester.tapAt(const Offset(400, 500));
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsNothing);
    });

    testWidgets('keeps suggestions visible when the field loses focus', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsOneWidget);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsOneWidget);

      await tester.tapAt(const Offset(400, 500));
      await tester.pumpAndSettle();
      expect(find.text('Juan Pérez'), findsNothing);
    });

    testWidgets('replaces the field with a chip after selection', (
      tester,
    ) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'Juan');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.tap(find.text('Juan Pérez'));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.byTooltip('Quitar selección'), findsOneWidget);
    });

    testWidgets(
      'clears the selection and restores the field when the chip is removed',
      (tester) async {
        var cleared = false;
        await _pump(tester, onCleared: () => cleared = true);

        await tester.enterText(find.byType(TextField), 'Juan');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump();
        await tester.tap(find.text('Juan Pérez'));
        await tester.pump();
        await tester.tap(find.byTooltip('Quitar selección'));
        await tester.pump();

        expect(cleared, isTrue);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byTooltip('Quitar selección'), findsNothing);
      },
    );

    testWidgets('shows a no results message when nothing matches', (
      tester,
    ) async {
      await _pump(tester, loadSuggestions: (ref, query) async => const []);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.text('Sin coincidencias'), findsOneWidget);
    });
  });
}

Future<void> _pump(
  WidgetTester tester, {
  FutureOr<List<ReportSuggestion>> Function(Ref ref, String query)?
  loadSuggestions,
  ValueChanged<ReportSuggestion>? onSelected,
  VoidCallback? onCleared,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: EntityAutocompleteField(
            loadSuggestions:
                loadSuggestions ?? (ref, query) async => suggestions,
            labelText: 'Cliente',
            hintText: 'Escribe el nombre del cliente',
            onSelected: onSelected ?? (_) {},
            onCleared: onCleared ?? () {},
          ),
        ),
      ),
    ),
  );
}

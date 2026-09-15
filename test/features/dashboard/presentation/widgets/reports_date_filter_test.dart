import 'package:arenero/features/dashboard/presentation/providers/reports_date_range_provider.dart';
import 'package:arenero/features/dashboard/presentation/widgets/reports_date_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportsDateFilter', () {
    testWidgets('shows a single calendar icon that opens the range menu', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_pumpFilter(container: container));

      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.byTooltip('Rango de fechas'), findsOneWidget);
    });

    testWidgets('opens the date picker from the start option of the menu', (
      tester,
    ) async {
      await tester.pumpWidget(_pumpFilter());

      await tester.tap(find.byTooltip('Rango de fechas'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Inicio '), findsOneWidget);
      await tester.tap(find.textContaining('Inicio '));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('restores the current month from the menu', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_pumpFilter(container: container));

      final notifier = container.read(reportsDateRangeProvider.notifier);
      notifier.onStartChanged(DateTime(2026, 1, 5));
      await tester.pump();

      await tester.tap(find.byTooltip('Rango de fechas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restablecer al mes actual'));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final state = container.read(reportsDateRangeProvider);
      expect(state.startDate, DateTime(now.year, now.month, 1));
      expect(state.endDate.year, now.year);
    });

    testWidgets('updates the end date without touching the start date', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_pumpFilter(container: container));
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final newEnd = DateTime(now.year, now.month, 20);
      final context = tester.element(find.byType(ReportsDateFilter));

      final applied = applyReportDateSelection(
        context,
        container,
        picked: newEnd,
        isStart: false,
      );
      await tester.pump();

      expect(applied, isTrue);
      final state = container.read(reportsDateRangeProvider);
      expect(state.endDate, newEnd);
      expect(state.startDate, start);
    });

    testWidgets('rejects an end date before the start date', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_pumpFilter(container: container));
      final context = tester.element(find.byType(ReportsDateFilter));
      final previousEnd = container.read(reportsDateRangeProvider).endDate;

      final applied = applyReportDateSelection(
        context,
        container,
        picked: previousEnd.subtract(const Duration(days: 40)),
        isStart: false,
      );
      await tester.pump();

      expect(applied, isFalse);
      expect(
        find.text('La fecha de fin no puede ser anterior a la de inicio.'),
        findsOneWidget,
      );
      expect(container.read(reportsDateRangeProvider).endDate, previousEnd);
    });

    testWidgets('rejects a start date after the end date', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_pumpFilter(container: container));
      final context = tester.element(find.byType(ReportsDateFilter));
      final previousStart = container.read(reportsDateRangeProvider).startDate;

      final applied = applyReportDateSelection(
        context,
        container,
        picked: previousStart.add(const Duration(days: 40)),
        isStart: true,
      );
      await tester.pump();

      expect(applied, isFalse);
      expect(
        find.text('La fecha de inicio no puede ser posterior a la de fin.'),
        findsOneWidget,
      );
      expect(container.read(reportsDateRangeProvider).startDate, previousStart);
    });
  });
}

Widget _pumpFilter({ProviderContainer? container}) {
  const child = MaterialApp(home: Scaffold(body: ReportsDateFilter()));
  if (container == null) return const ProviderScope(child: child);
  return UncontrolledProviderScope(container: container, child: child);
}

import 'package:arenero/features/dashboard/presentation/providers/reports_date_range_provider.dart';
import 'package:arenero/features/dashboard/presentation/utils/report_formatters.dart';
import 'package:arenero/features/dashboard/presentation/widgets/reports_date_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportsDateFilter', () {
    testWidgets('shows the start and end dates in two separate buttons', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_pumpFilter(container: container));
      final range = container.read(reportsDateRangeProvider);

      expect(find.text(formatReportShortDate(range.startDate)), findsOneWidget);
      expect(find.text(formatReportShortDate(range.endDate)), findsOneWidget);
      expect(find.byTooltip('Restablecer al mes actual'), findsOneWidget);
    });

    testWidgets('opens the start date picker from its button', (tester) async {
      await tester.pumpWidget(_pumpFilter());

      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
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

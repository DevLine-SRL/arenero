import 'package:arenero/features/dashboard/presentation/widgets/reports_pagination_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _pump(
  WidgetTester tester, {
  required int totalCount,
  required int page,
  required int pageSize,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ReportsPaginationBar(
        totalCount: totalCount,
        page: page,
        pageSize: pageSize,
        onPrevious: () {},
        onNext: () {},
      ),
    ),
  );
}

void main() {
  group('ReportsPaginationBar', () {
    testWidgets('shows the current page indicator centered', (tester) async {
      await tester.pumpWidget(
        _pump(tester, totalCount: 25, page: 2, pageSize: 8),
      );

      expect(find.text('3 / 4'), findsOneWidget);
      expect(find.text('Anterior'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('disables both buttons when there is a single page', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(tester, totalCount: 3, page: 0, pageSize: 8),
      );

      expect(find.text('1 / 1'), findsOneWidget);
      final previous = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Anterior'),
      );
      final next = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Siguiente'),
      );

      expect(previous.onPressed, isNull);
      expect(next.onPressed, isNull);
    });

    testWidgets('disables previous on the first page and next on the last', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(tester, totalCount: 20, page: 0, pageSize: 8),
      );

      var previous = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Anterior'),
      );
      var next = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Siguiente'),
      );
      expect(previous.onPressed, isNull);
      expect(next.onPressed, isNotNull);

      await tester.pumpWidget(
        _pump(tester, totalCount: 20, page: 2, pageSize: 8),
      );

      previous = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Anterior'),
      );
      next = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Siguiente'),
      );
      expect(previous.onPressed, isNotNull);
      expect(next.onPressed, isNull);
    });

    testWidgets('shows zero results without pagination controls enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(tester, totalCount: 0, page: 0, pageSize: 8),
      );

      expect(find.text('0 / 0'), findsOneWidget);
      final previous = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Anterior'),
      );
      expect(previous.onPressed, isNull);
    });
  });
}

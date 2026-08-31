import 'package:arenero/features/dashboard/presentation/providers/reports_date_range_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportsDateRange', () {
    test('defaults to the month in progress until today', () {
      final now = DateTime(2026, 8, 13);

      final filter = ReportsDateRangeFilter.defaultFor(now);

      expect(filter.startDate, DateTime(2026, 8, 1));
      expect(filter.endDate, now);
    });

    test('keeps the range coherent when the end date is before the start', () {
      final filter = ReportsDateRangeFilter.defaultFor(
        DateTime(2026, 8, 13),
      ).copyWith(endDate: DateTime(2026, 7, 1));

      expect(filter.startDate.isAfter(filter.endDate), isTrue);
    });

    test('updates the start date without touching the end date', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(reportsDateRangeProvider.notifier);
      final initialEnd = container.read(reportsDateRangeProvider).endDate;
      final newStart = DateTime(2026, 8, 5);

      notifier.onStartChanged(newStart);

      final state = container.read(reportsDateRangeProvider);
      expect(state.startDate, newStart);
      expect(state.endDate, initialEnd);
    });

    test('updates the end date without touching the start date', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(reportsDateRangeProvider.notifier);
      final initialStart = container.read(reportsDateRangeProvider).startDate;
      final newEnd = DateTime(2026, 8, 20);

      notifier.onEndChanged(newEnd);

      final state = container.read(reportsDateRangeProvider);
      expect(state.endDate, newEnd);
      expect(state.startDate, initialStart);
    });

    test('reset restores the default month in progress', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(reportsDateRangeProvider.notifier);
      notifier.onStartChanged(DateTime(2025, 1, 1));
      notifier.onEndChanged(DateTime(2025, 1, 31));

      notifier.reset();

      final state = container.read(reportsDateRangeProvider);
      expect(state.startDate, DateTime(2026, 8, 1));
    });
  });
}

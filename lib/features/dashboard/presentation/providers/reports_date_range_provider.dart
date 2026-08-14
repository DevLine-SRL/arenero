import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_date_range_provider.g.dart';

@riverpod
class ReportsDateRange extends _$ReportsDateRange {
  @override
  ReportsDateRangeFilter build() =>
      ReportsDateRangeFilter.defaultFor(DateTime.now());

  void onStartChanged(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void onEndChanged(DateTime date) {
    state = state.copyWith(endDate: date);
  }

  void reset() => state = ReportsDateRangeFilter.defaultFor(DateTime.now());
}

class ReportsDateRangeFilter {
  final DateTime startDate;
  final DateTime endDate;

  const ReportsDateRangeFilter({
    required this.startDate,
    required this.endDate,
  });

  factory ReportsDateRangeFilter.defaultFor(DateTime now) {
    return ReportsDateRangeFilter(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );
  }

  ReportsDateRangeFilter copyWith({DateTime? startDate, DateTime? endDate}) {
    return ReportsDateRangeFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

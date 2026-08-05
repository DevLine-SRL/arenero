import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_history_date_range_provider.g.dart';

@riverpod
class SalesHistoryDateRange extends _$SalesHistoryDateRange {
  @override
  DateRangeFilter build() => const DateRangeFilter();

  void onStartChanged(DateTime? date) =>
      state = DateRangeFilter(startDate: date, endDate: state.endDate);

  void onEndChanged(DateTime? date) =>
      state = DateRangeFilter(startDate: state.startDate, endDate: date);

  void clear() => state = const DateRangeFilter();
}

class DateRangeFilter {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeFilter({this.startDate, this.endDate});

  bool get isActive => startDate != null || endDate != null;

  bool includes(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (startDate != null &&
        day.isBefore(
          DateTime(startDate!.year, startDate!.month, startDate!.day),
        )) {
      return false;
    }
    if (endDate != null &&
        day.isAfter(DateTime(endDate!.year, endDate!.month, endDate!.day))) {
      return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is DateRangeFilter &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate);
}

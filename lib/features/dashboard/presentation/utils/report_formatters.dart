String formatReportAmount(double value) {
  final negative = value < 0;
  final abs = value.abs().round();
  final buffer = StringBuffer();
  final whole = abs.toString();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '${negative ? '-' : ''}Bs. $buffer';
}

String formatReportQuantity(double value) {
  final fixed = value.toStringAsFixed(2);
  if (fixed.endsWith('.00')) return fixed.substring(0, fixed.length - 3);
  if (fixed.endsWith('0')) return fixed.substring(0, fixed.length - 1);
  return fixed;
}

String formatReportDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

const _shortMonths = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatReportShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '$day ${_shortMonths[date.month - 1]} ${date.year}';
}

String formatReportDateRange(DateTime start, DateTime end) {
  final startDay = start.day.toString().padLeft(2, '0');
  final endDay = end.day.toString().padLeft(2, '0');
  if (start.year == end.year) {
    if (start.month == end.month) {
      return '$startDay - $endDay ${_shortMonths[end.month - 1]} ${end.year}';
    }
    return '$startDay ${_shortMonths[start.month - 1]} - $endDay ${_shortMonths[end.month - 1]} ${end.year}';
  }
  return '${formatReportShortDate(start)} - ${formatReportShortDate(end)}';
}

String formatReportUnit(String unit) {
  return switch (unit) {
    'm3' => 'm³',
    'bag' => 'bolsa',
    'kg' => 'kg',
    'ton' => 'ton',
    'unit' => 'unidad',
    _ => unit,
  };
}

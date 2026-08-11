const _esMonths = [
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

String formatAmount(double value) {
  final negative = value < 0;
  final abs = value.abs().toStringAsFixed(2);
  return '${negative ? '-' : ''}Bs. ${_addThousandsSeparator(abs)}';
}

String _addThousandsSeparator(String amount) {
  final parts = amount.split('.');
  final whole = parts[0];
  final decimals = parts.length > 1 ? '.${parts[1]}' : '';
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '$buffer$decimals';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _esMonths[date.month - 1];
  return '$day $month ${date.year}';
}

const _diacritics = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

String normalizeSearchText(String value) {
  final buffer = StringBuffer();
  for (final char in value.toLowerCase().split('')) {
    buffer.write(_diacritics[char] ?? char);
  }
  return buffer.toString();
}

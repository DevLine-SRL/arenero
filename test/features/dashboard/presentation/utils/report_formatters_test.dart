import 'package:arenero/features/dashboard/presentation/utils/report_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatReportAmount', () {
    test('formats amounts with thousands separator and no decimals', () {
      expect(formatReportAmount(1234.56), 'Bs. 1,235');
    });

    test('rounds to the nearest whole number', () {
      expect(formatReportAmount(999.4), 'Bs. 999');
      expect(formatReportAmount(999.5), 'Bs. 1,000');
    });

    test('keeps the sign for negative amounts', () {
      expect(formatReportAmount(-1500), '-Bs. 1,500');
    });

    test('formats zero', () {
      expect(formatReportAmount(0), 'Bs. 0');
    });
  });

  group('formatReportQuantity', () {
    test('drops the decimals when the quantity is whole', () {
      expect(formatReportQuantity(2.0), '2');
      expect(formatReportQuantity(10.00), '10');
    });

    test('keeps one decimal when present', () {
      expect(formatReportQuantity(2.5), '2.5');
    });

    test('keeps two decimals when needed', () {
      expect(formatReportQuantity(2.25), '2.25');
    });
  });

  group('formatReportDate', () {
    test('formats dates as dd/mm/yyyy', () {
      expect(formatReportDate(DateTime(2026, 8, 5)), '05/08/2026');
    });
  });

  group('formatReportShortDate', () {
    test('formats dates as day month year', () {
      expect(formatReportShortDate(DateTime(2026, 8, 13)), '13 ago 2026');
      expect(formatReportShortDate(DateTime(2025, 12, 20)), '20 dic 2025');
      expect(formatReportShortDate(DateTime(2026, 1, 14)), '14 ene 2026');
    });
  });

  group('formatReportDateRange', () {
    test('shows the year once when both dates fall in the same month', () {
      expect(
        formatReportDateRange(DateTime(2026, 8, 7), DateTime(2026, 8, 14)),
        '07 - 14 ago 2026',
      );
    });

    test('shows the year once when both dates fall in the same year', () {
      expect(
        formatReportDateRange(DateTime(2026, 7, 1), DateTime(2026, 8, 14)),
        '01 jul - 14 ago 2026',
      );
    });

    test('shows the year on both ends when the range crosses years', () {
      expect(
        formatReportDateRange(DateTime(2025, 12, 20), DateTime(2026, 1, 14)),
        '20 dic 2025 - 14 ene 2026',
      );
    });
  });

  group('formatReportUnit', () {
    test('maps known units to readable labels', () {
      expect(formatReportUnit('m3'), 'm³');
      expect(formatReportUnit('bag'), 'bolsa');
      expect(formatReportUnit('kg'), 'kg');
      expect(formatReportUnit('ton'), 'ton');
      expect(formatReportUnit('unit'), 'unidad');
    });

    test('keeps unknown units as-is', () {
      expect(formatReportUnit('pallet'), 'pallet');
    });
  });
}

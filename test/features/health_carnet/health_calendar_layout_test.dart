import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_calendar_layout.dart';

void main() {
  // `firstDayOfWeekIndex` is 0 = Sunday (en) … 1 = Monday (de/es/fr/hu/pt).
  const sunday = 0;
  const monday = 1;

  group('leadingBlankDays', () {
    test('September 2026 starts on a Tuesday', () {
      final month = DateTime(2026, 9);
      expect(leadingBlankDays(month, sunday), 2);
      expect(leadingBlankDays(month, monday), 1);
    });

    test('a month starting on Sunday is flush in en and shifted in fr', () {
      final month = DateTime(2026, 11); // 1 Nov 2026 is a Sunday
      expect(leadingBlankDays(month, sunday), 0);
      expect(leadingBlankDays(month, monday), 6);
    });

    test('a month starting on Monday is flush in fr and shifted in en', () {
      final month = DateTime(2026, 6); // 1 Jun 2026 is a Monday
      expect(leadingBlankDays(month, monday), 0);
      expect(leadingBlankDays(month, sunday), 1);
    });
  });

  group('daysInMonth', () {
    test('handles February in leap and common years', () {
      expect(daysInMonth(DateTime(2024, 2)), 29);
      expect(daysInMonth(DateTime(2026, 2)), 28);
    });

    test('handles December without overflowing the year', () {
      expect(daysInMonth(DateTime(2026, 12)), 31);
    });
  });
}

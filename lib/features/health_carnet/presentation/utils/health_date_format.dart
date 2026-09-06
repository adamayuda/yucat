/// Date and number formatting for the carnet.
///
/// ⚠️ **The first hand-written `DateFormat` in the app.** `intl` was already a
/// dependency but was imported only by the generated `app_localizations*.dart` —
/// no screen had ever shown a date, because no feature had ever stored one.
///
/// Every function takes the locale explicitly rather than reading an ambient
/// one, so a widget always passes `Localizations.localeOf(context).languageCode`
/// and the same call is testable without a `BuildContext`.
library;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';


/// "12 Jan 2026" — the timeline and due-date default.
String healthFormatDate(DateTime date, String locale) =>
    DateFormat.yMMMd(locale).format(date);

/// "January 2027" — for a date far enough out that a day would be false
/// precision. The mockup's *"Prévu en janvier 2027"*.
String healthFormatMonthYear(DateTime date, String locale) =>
    DateFormat.yMMMM(locale).format(date);

/// "Jan" — the weight chart's x-axis.
String healthFormatMonthShort(DateTime date, String locale) =>
    DateFormat.MMM(locale).format(date);

/// A due date at the precision it deserves.
///
/// Under two months out the exact day matters and the owner can act on it;
/// beyond that, a day-precise date read off an approximated schedule is
/// false confidence, so it degrades to the month.
String healthFormatDueDate(DateTime date, int daysUntil, String locale) =>
    daysUntil.abs() <= 60
        ? healthFormatDate(date, locale)
        : healthFormatMonthYear(date, locale);

/// Bucket for the relative "in N days / in N months" pill. Returned as a record
/// so the caller picks the ARB string — pluralisation belongs in the ARBs, not
/// in a string built here.
({int value, HealthRelativeUnit unit}) healthRelativeParts(int daysUntil) {
  final days = daysUntil.abs();
  if (days < 31) return (value: days, unit: HealthRelativeUnit.day);
  if (days < 365) {
    return (value: (days / 30.4375).round(), unit: HealthRelativeUnit.month);
  }
  return (value: (days / 365.25).round(), unit: HealthRelativeUnit.year);
}

enum HealthRelativeUnit { day, month, year }

/// "4.8" / "4,8" — a weight, with the locale's decimal separator.
String healthFormatKg(double kg, String locale) =>
    NumberFormat('0.0', locale).format(kg);

/// "+0.3" / "-0,2" — a signed weight change. The sign is explicit because the
/// direction is the whole point of the figure.
String healthFormatKgDelta(double deltaKg, String locale) {
  final formatted = NumberFormat('0.0', locale).format(deltaKg.abs());
  return deltaKg < 0 ? '-$formatted' : '+$formatted';
}

/// Locale code for the current build context, for the formatters above.
String healthLocaleOf(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

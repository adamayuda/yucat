/// Month-grid arithmetic, kept free of Flutter so it can be exercised on its own.
///
/// The caller supplies `MaterialLocalizations.firstDayOfWeekIndex`; nothing here
/// needs a `BuildContext`.
library;

/// Blank cells before the 1st of [month].
///
/// `DateTime.weekday` is 1=Mon..7=Sun while `MaterialLocalizations
/// .firstDayOfWeekIndex` is 0=Sun..6=Sat, so the `% 7` converts the former to
/// the latter's frame before the subtraction. Getting this wrong shifts a whole
/// month by a day, and it shifts differently per locale — the app ships six,
/// and they do not all start the week on the same day.
///
/// Split out of the calendar widget so the arithmetic can be exercised without
/// building one — this file imports no Flutter.
int leadingBlankDays(DateTime month, int firstDayOfWeekIndex) {
  final first = DateTime(month.year, month.month);
  return (first.weekday % 7 - firstDayOfWeekIndex + 7) % 7;
}

/// Days in [month]. Day 0 of the following month is the last of this one, which
/// also gets February right in a leap year.
int daysInMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0).day;

import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';

/// A calendar day in the Umm al-Qura Hijri calendar (the official Saudi
/// calendar, and the one most Gulf users read their zakat year from).
///
/// Wraps `package:hijri` for the table-driven conversion only. That package
/// keeps its display language in a mutable static, so nothing here ever
/// formats through it — month names come from the app's own localizations
/// (see `hijriMonthName` in `theme/strings.dart`).
///
/// The Umm al-Qura table covers 1356–1500 AH (14 Mar 1937 – 16 Nov 2077).
/// Every conversion outside that window returns null rather than throwing,
/// so callers fall back to Gregorian instead of crashing on an odd date.
class HijriDate extends Equatable implements Comparable<HijriDate> {
  final int year;
  final int month;
  final int day;

  const HijriDate(this.year, this.month, this.day);

  static const int firstSupportedYear = 1356;
  static const int lastSupportedYear = 1500;

  static final DateTime firstSupportedDay = DateTime(1937, 3, 14);
  static final DateTime lastSupportedDay = DateTime(2077, 11, 16);

  /// The Hijri day containing [date]'s local calendar day, or null when it
  /// falls outside the Umm al-Qura table.
  static HijriDate? fromGregorian(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(firstSupportedDay) || day.isAfter(lastSupportedDay)) return null;
    try {
      final h = HijriCalendar.fromDate(day);
      return HijriDate(h.hYear, h.hMonth, h.hDay);
    } on ArgumentError {
      return null;
    }
  }

  /// Number of days (29 or 30) in [month] of [year], or null outside the
  /// table.
  static int? daysInMonth(int year, int month) {
    if (month < 1 || month > 12) return null;
    if (year < firstSupportedYear || year > lastSupportedYear) return null;
    try {
      return HijriCalendar().getDaysInMonth(year, month);
    } on ArgumentError {
      return null;
    }
  }

  /// Whether this names a real day in the table (month 1–12, day within that
  /// month's actual 29/30-day length).
  bool get isValid {
    final length = daysInMonth(year, month);
    return length != null && day >= 1 && day <= length;
  }

  /// Local midnight of the matching Gregorian day, or null when invalid.
  DateTime? toGregorian() {
    if (!isValid) return null;
    try {
      final g = HijriCalendar().hijriToGregorian(year, month, day);
      return DateTime(g.year, g.month, g.day);
    } on ArgumentError {
      return null;
    }
  }

  /// The same day [years] Hijri years later. A 30th that doesn't exist in
  /// the target month (it may only have 29 days that year) clamps to the
  /// 29th, so an anniversary never silently rolls into the next month.
  HijriDate? addYears(int years) {
    final targetYear = year + years;
    final length = daysInMonth(targetYear, month);
    if (length == null) return null;
    return HijriDate(targetYear, month, day > length ? length : day);
  }

  @override
  int compareTo(HijriDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  List<Object?> get props => [year, month, day];

  @override
  String toString() => '$year-$month-$day AH';
}

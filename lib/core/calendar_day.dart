/// A calendar day in the phone's local time zone, such as "8 Nov 2026".
///
/// Stored as a whole number of days since 1970-01-01, never as a
/// `DateTime`. Daily goals and streaks are counted per [CalendarDay], so a
/// time-zone or daylight-saving shift can never move a walk to another day.
extension type const CalendarDay._(int daysSinceEpoch) {
  /// The local calendar day that [moment] falls on.
  factory CalendarDay.of(DateTime moment) {
    final local = moment.toLocal();
    // Rebuild the date at UTC midnight so DST can't shift it by an hour.
    final utcMidnight = DateTime.utc(local.year, local.month, local.day);
    final days =
        (utcMidnight.millisecondsSinceEpoch / Duration.millisecondsPerDay)
            .floor();
    return CalendarDay._(days);
  }

  /// Restores a day from its stored serial number.
  const CalendarDay.fromSerial(int serial) : daysSinceEpoch = serial;

  /// The day [days] after this one (or before, if negative).
  CalendarDay plusDays(int days) => CalendarDay._(daysSinceEpoch + days);

  /// Whether this day comes before [other].
  bool isBefore(CalendarDay other) => daysSinceEpoch < other.daysSinceEpoch;
}

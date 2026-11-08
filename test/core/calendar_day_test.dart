import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/core/calendar_day.dart';

void main() {
  test('known dates have known serial numbers', () {
    expect(CalendarDay.of(DateTime(1970)).daysSinceEpoch, 0);
    expect(CalendarDay.of(DateTime(2000)).daysSinceEpoch, 10957);
  });

  test('every moment of a local day maps to the same day', () {
    final day = CalendarDay.of(DateTime(2026, 11, 8, 12));
    expect(CalendarDay.of(DateTime(2026, 11, 8)), day);
    expect(CalendarDay.of(DateTime(2026, 11, 8, 23, 59, 59)), day);
    expect(CalendarDay.of(DateTime(2026, 11, 9)), day.plusDays(1));
  });

  test('consecutive local days always differ by exactly one, all year', () {
    // Walks every day of 2026, so it crosses any daylight-saving change in
    // the time zone the tests run in.
    var previous = CalendarDay.of(DateTime(2025, 12, 31, 12));
    for (var offset = 0; offset < 365; offset++) {
      final early = CalendarDay.of(DateTime(2026, 1, 1 + offset, 0, 30));
      final late = CalendarDay.of(DateTime(2026, 1, 1 + offset, 23, 30));
      final reason = 'offset=$offset';
      expect(early, late, reason: reason);
      expect(early, previous.plusDays(1), reason: reason);
      previous = early;
    }
  });

  test('a stored serial round-trips', () {
    final day = CalendarDay.of(DateTime(2026, 11, 8));
    expect(CalendarDay.fromSerial(day.daysSinceEpoch), day);
  });

  test('isBefore compares days', () {
    final today = CalendarDay.of(DateTime(2026, 11, 8));
    expect(today.isBefore(today.plusDays(1)), isTrue);
    expect(today.isBefore(today), isFalse);
  });
}

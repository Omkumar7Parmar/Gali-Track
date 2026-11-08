import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/core/units.dart';

void main() {
  test('kilograms convert to whole grams, rounding half-way up', () {
    expect(Grams.fromKilograms(65), const Grams(65000));
    expect(Grams.fromKilograms(65.25), const Grams(65250));
    expect(Grams.fromKilograms(0.0005), const Grams(1));
  });

  test('kilometres convert to whole metres, rounding half-way up', () {
    expect(Meters.fromKilometers(4), const Meters(4000));
    expect(Meters.fromKilometers(0.0005), const Meters(1));
  });

  test('grams round-trip through kilograms for every picker value', () {
    for (var grams = 25000; grams <= 250000; grams += 500) {
      expect(
        Grams.fromKilograms(Grams(grams).inKilograms),
        Grams(grams),
        reason: 'grams=$grams',
      );
    }
  });

  test('metres round-trip through kilometres for every picker value', () {
    for (var meters = 500; meters <= 30000; meters += 500) {
      expect(
        Meters.fromKilometers(Meters(meters).inKilometers),
        Meters(meters),
        reason: 'meters=$meters',
      );
    }
  });
}

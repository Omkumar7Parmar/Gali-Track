import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/core/numeric.dart';

/// Independent oracle: the nearest multiple of [step], found by comparing
/// the multiples on either side (ties go up), then clamped.
int nearestMultipleOracle(double value, int step, int min, int max) {
  final below = (value / step).floor() * step;
  final above = below + step;
  final nearest = (value - below) < (above - value) ? below : above;
  return nearest < min ? min : (nearest > max ? max : nearest);
}

void main() {
  group('snapToStep', () {
    test('rounds half-way values up', () {
      expect(snapToStep(6249, step: 500, min: 1000, max: 30000), 6000);
      expect(snapToStep(6250, step: 500, min: 1000, max: 30000), 6500);
    });

    test('clamps to the range', () {
      expect(snapToStep(10, step: 500, min: 1000, max: 30000), 1000);
      expect(snapToStep(99999, step: 500, min: 1000, max: 30000), 30000);
    });

    test('is total: NaN and infinities map to a bound', () {
      expect(snapToStep(double.nan, step: 500, min: 1000, max: 30000), 1000);
      expect(
        snapToStep(double.infinity, step: 500, min: 1000, max: 30000),
        30000,
      );
      expect(
        snapToStep(double.negativeInfinity, step: 500, min: 1000, max: 30000),
        1000,
      );
    });

    test('matches the nearest-multiple oracle (fuzz)', () {
      final random = Random(0x6A11);
      for (var seed = 0; seed < 1000; seed++) {
        final value = random.nextDouble() * 40000;
        final actual = snapToStep(value, step: 500, min: 1000, max: 30000);
        expect(
          actual,
          nearestMultipleOracle(value, 500, 1000, 30000),
          reason: 'seed=$seed value=$value',
        );
      }
    });
  });

  group('progressFraction', () {
    test('handles the edges without dividing by zero', () {
      expect(progressFraction(0, 6000), 0);
      expect(progressFraction(100, 0), 0);
      expect(progressFraction(-5, 6000), 0);
      expect(progressFraction(9000, 6000), 1);
      expect(progressFraction(3000, 6000), closeTo(0.5, 1e-9));
    });

    test('stays within 0..1 and never decreases as progress grows (fuzz)', () {
      final random = Random(0xF17);
      for (var seed = 0; seed < 500; seed++) {
        final target = random.nextInt(30000) + 1;
        final current = random.nextInt(40000);
        final fraction = progressFraction(current, target);
        final next = progressFraction(current + 1, target);
        final reason = 'seed=$seed current=$current target=$target';
        expect(fraction, inInclusiveRange(0, 1), reason: reason);
        expect(next, greaterThanOrEqualTo(fraction), reason: reason);
      }
    });
  });
}

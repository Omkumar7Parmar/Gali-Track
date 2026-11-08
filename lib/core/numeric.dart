/// Small, total number helpers shared by the view models.
///
/// "Total" means they return a value for every input and never throw.
library;

/// Rounds [value] to the nearest multiple of [step], then clamps it to
/// [min]..[max]. NaN becomes [min]; infinities become the nearest bound.
int snapToStep(
  double value, {
  required int step,
  required int min,
  required int max,
}) {
  assert(min <= max, 'min ($min) must not exceed max ($max)');
  if (value.isNaN) return min;
  if (value.isInfinite) return value > 0 ? max : min;
  final snapped = step <= 0 ? value.round() : (value / step).round() * step;
  return snapped.clamp(min, max);
}

/// How far [current] is towards [target], from 0 to 1.
///
/// A target of zero or less counts as no progress, never a division by zero.
double progressFraction(int current, int target) {
  if (target <= 0 || current <= 0) return 0;
  return current >= target ? 1 : current / target;
}

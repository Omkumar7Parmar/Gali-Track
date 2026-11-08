/// Typed quantities, stored as whole numbers of an SI unit.
///
/// These are zero-cost wrappers around `int`: they stop a weight in grams
/// from being passed where a distance in metres is expected.
library;

/// A mass in whole grams.
extension type const Grams(int value) {
  /// Rounds [kilograms] to the nearest gram.
  factory Grams.fromKilograms(double kilograms) =>
      Grams((kilograms * 1000).round());

  double get inKilograms => value / 1000;
}

/// A body height in whole centimetres.
extension type const Centimeters(int value) {}

/// A distance in whole metres.
extension type const Meters(int value) {
  /// Rounds [kilometers] to the nearest metre.
  factory Meters.fromKilometers(double kilometers) =>
      Meters((kilometers * 1000).round());

  double get inKilometers => value / 1000;
}

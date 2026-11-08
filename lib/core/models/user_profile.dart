import 'package:galitrack/core/units.dart';
import 'package:meta/meta.dart';

/// The body measurements used to estimate calories and stride length.
@immutable
final class UserProfile {
  const UserProfile({required this.weight, this.height});

  /// Starting values shown in onboarding before the user adjusts them.
  static const suggestedWeight = Grams(65000);
  static const suggestedHeight = Centimeters(165);

  // Allowed ranges, mirrored by CHECK constraints in the database.
  static const minWeight = Grams(25000);
  static const maxWeight = Grams(250000);
  static const minHeight = Centimeters(100);
  static const maxHeight = Centimeters(250);

  // How finely the pickers adjust each value.
  static const weightIncrement = Grams(500);
  static const heightIncrement = Centimeters(1);

  final Grams weight;

  /// Optional; null when the user skipped it.
  final Centimeters? height;

  @override
  bool operator ==(Object other) =>
      other is UserProfile && other.weight == weight && other.height == height;

  @override
  int get hashCode => Object.hash(weight, height);

  @override
  String toString() => 'UserProfile(${weight.value} g, ${height?.value} cm)';
}

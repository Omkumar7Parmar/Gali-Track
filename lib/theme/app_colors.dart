import 'package:flutter/material.dart';
import 'package:galitrack/theme/primitives.dart';

/// Semantic colour slots GaliTrack needs beyond the Material [ColorScheme].
///
/// Read with [AppColors.of]. Steps are always marigold and distance always
/// teal, in every screen and both themes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.stepsAccent,
    required this.distanceAccent,
    required this.ringTrack,
  });

  /// Progress arcs and highlights that mean "steps".
  final Color stepsAccent;

  /// Progress arcs and highlights that mean "distance".
  final Color distanceAccent;

  /// The unfilled part of a progress ring. Decorative only: the ring's
  /// meaning is always carried by a text label too.
  final Color ringTrack;

  static const light = AppColors(
    stepsAccent: Primitives.marigold54,
    distanceAccent: Primitives.teal49,
    ringTrack: Primitives.neutral89,
  );

  static const dark = AppColors(
    stepsAccent: Primitives.marigold81,
    distanceAccent: Primitives.teal81,
    ringTrack: Primitives.neutral32,
  );

  /// Asserts instead of falling back: a fallback would ship colours that no
  /// test has checked.
  static AppColors of(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    assert(
      colors != null,
      'AppColors missing: build ThemeData via buildAppTheme().',
    );
    return colors!;
  }

  @override
  AppColors copyWith({
    Color? stepsAccent,
    Color? distanceAccent,
    Color? ringTrack,
  }) {
    return AppColors(
      stepsAccent: stepsAccent ?? this.stepsAccent,
      distanceAccent: distanceAccent ?? this.distanceAccent,
      ringTrack: ringTrack ?? this.ringTrack,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      stepsAccent: Color.lerp(stepsAccent, other.stepsAccent, t)!,
      distanceAccent: Color.lerp(distanceAccent, other.distanceAccent, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
    );
  }
}

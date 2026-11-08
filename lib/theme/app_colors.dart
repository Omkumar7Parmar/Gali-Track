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
    required this.stepsAccentSoft,
    required this.distanceAccent,
    required this.distanceAccentSoft,
    required this.ringTrack,
    required this.laneLine,
  });

  /// Progress arcs and highlights that mean "steps".
  final Color stepsAccent;

  /// Where a steps arc starts its gradient sweep, before deepening into
  /// [stepsAccent].
  final Color stepsAccentSoft;

  /// Progress arcs and highlights that mean "distance".
  final Color distanceAccent;

  /// Where a distance arc starts its gradient sweep.
  final Color distanceAccentSoft;

  /// The unfilled part of a progress ring. Decorative only: the ring's
  /// meaning is always carried by a text label too.
  final Color ringTrack;

  /// The faint sketch of lanes behind hero areas. Pure texture.
  final Color laneLine;

  static const light = AppColors(
    stepsAccent: Primitives.marigold54,
    stepsAccentSoft: Primitives.marigold81,
    distanceAccent: Primitives.teal49,
    distanceAccentSoft: Primitives.teal81,
    ringTrack: Primitives.neutral89,
    laneLine: Primitives.neutral91,
  );

  static const dark = AppColors(
    stepsAccent: Primitives.marigold81,
    stepsAccentSoft: Primitives.marigold92,
    distanceAccent: Primitives.teal81,
    distanceAccentSoft: Primitives.teal91,
    ringTrack: Primitives.neutral32,
    laneLine: Primitives.neutral28,
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
    Color? stepsAccentSoft,
    Color? distanceAccent,
    Color? distanceAccentSoft,
    Color? ringTrack,
    Color? laneLine,
  }) {
    return AppColors(
      stepsAccent: stepsAccent ?? this.stepsAccent,
      stepsAccentSoft: stepsAccentSoft ?? this.stepsAccentSoft,
      distanceAccent: distanceAccent ?? this.distanceAccent,
      distanceAccentSoft: distanceAccentSoft ?? this.distanceAccentSoft,
      ringTrack: ringTrack ?? this.ringTrack,
      laneLine: laneLine ?? this.laneLine,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      stepsAccent: Color.lerp(stepsAccent, other.stepsAccent, t)!,
      stepsAccentSoft: Color.lerp(stepsAccentSoft, other.stepsAccentSoft, t)!,
      distanceAccent: Color.lerp(distanceAccent, other.distanceAccent, t)!,
      distanceAccentSoft: Color.lerp(
        distanceAccentSoft,
        other.distanceAccentSoft,
        t,
      )!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      laneLine: Color.lerp(laneLine, other.laneLine, t)!,
    );
  }
}

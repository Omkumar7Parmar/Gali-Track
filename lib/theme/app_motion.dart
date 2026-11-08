import 'package:flutter/material.dart';

/// Animation durations and curves, read with [AppMotion.of].
///
/// Always pass a duration through [resolveMotion] so animations switch off
/// when the phone's "remove animations" setting is on.
@immutable
class AppMotion extends ThemeExtension<AppMotion> {
  const AppMotion({
    required this.short,
    required this.medium,
    required this.long,
    required this.standard,
    required this.enter,
    required this.exit,
  });

  final Duration short;
  final Duration medium;
  final Duration long;

  /// For movement that starts and ends on screen.
  final Curve standard;

  /// For things arriving on screen.
  final Curve enter;

  /// For things leaving the screen.
  final Curve exit;

  static const standardSet = AppMotion(
    short: Duration(milliseconds: 150),
    medium: Duration(milliseconds: 300),
    long: Duration(milliseconds: 500),
    standard: Easing.standard,
    enter: Easing.emphasizedDecelerate,
    exit: Easing.emphasizedAccelerate,
  );

  static AppMotion of(BuildContext context) {
    final motion = Theme.of(context).extension<AppMotion>();
    assert(
      motion != null,
      'AppMotion missing: build ThemeData via buildAppTheme().',
    );
    return motion!;
  }

  // Durations and curves are not interpolated: a theme change never animates
  // them, so snapping at the halfway point is the honest behaviour.
  @override
  AppMotion lerp(covariant AppMotion? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }

  @override
  AppMotion copyWith({
    Duration? short,
    Duration? medium,
    Duration? long,
    Curve? standard,
    Curve? enter,
    Curve? exit,
  }) {
    return AppMotion(
      short: short ?? this.short,
      medium: medium ?? this.medium,
      long: long ?? this.long,
      standard: standard ?? this.standard,
      enter: enter ?? this.enter,
      exit: exit ?? this.exit,
    );
  }
}

/// Returns [full], or [Duration.zero] when the user turned animations off.
///
/// Reduced motion means no motion, never a shorter animation.
Duration resolveMotion(BuildContext context, Duration full) {
  return MediaQuery.disableAnimationsOf(context) ? Duration.zero : full;
}

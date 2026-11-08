import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Corner radii, shape factories and stroke widths, read with [AppShapes.of].
///
/// Components ask for a silhouette ([cardShape], [pillShape]) instead of
/// naming a radius, so reshaping the app is one edit here.
@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  const AppShapes({
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.ringStroke,
    required this.ringStrokeThin,
    required this.outlineWidth,
    required this.selectedOutlineWidth,
  });

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;

  /// Stroke width of a full-size progress ring.
  final double ringStroke;

  /// Stroke width of a small progress ring, such as in previews.
  final double ringStrokeThin;

  /// Border of an unselected choice card.
  final double outlineWidth;

  /// Border of a selected choice card: thicker, so selection never depends
  /// on colour alone.
  final double selectedOutlineWidth;

  static const standard = AppShapes(
    radiusSmall: 12,
    radiusMedium: 20,
    radiusLarge: 28,
    ringStroke: 14,
    ringStrokeThin: 7,
    outlineWidth: 1,
    selectedOutlineWidth: 3,
  );

  static AppShapes of(BuildContext context) {
    final shapes = Theme.of(context).extension<AppShapes>();
    assert(
      shapes != null,
      'AppShapes missing: build ThemeData via buildAppTheme().',
    );
    return shapes!;
  }

  /// The silhouette of every card.
  RoundedRectangleBorder cardShape({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
      side: side,
    );
  }

  /// A smaller rounded rectangle for inner panels and snack bars.
  RoundedRectangleBorder panelShape({BorderSide side = BorderSide.none}) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      side: side,
    );
  }

  /// Fully rounded ends, used by primary buttons.
  StadiumBorder pillShape() => const StadiumBorder();

  @override
  AppShapes copyWith({
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? ringStroke,
    double? ringStrokeThin,
    double? outlineWidth,
    double? selectedOutlineWidth,
  }) {
    return AppShapes(
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      ringStroke: ringStroke ?? this.ringStroke,
      ringStrokeThin: ringStrokeThin ?? this.ringStrokeThin,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      selectedOutlineWidth: selectedOutlineWidth ?? this.selectedOutlineWidth,
    );
  }

  @override
  AppShapes lerp(covariant AppShapes? other, double t) {
    if (other == null) return this;
    return AppShapes(
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t)!,
      radiusMedium: lerpDouble(radiusMedium, other.radiusMedium, t)!,
      radiusLarge: lerpDouble(radiusLarge, other.radiusLarge, t)!,
      ringStroke: lerpDouble(ringStroke, other.ringStroke, t)!,
      ringStrokeThin: lerpDouble(ringStrokeThin, other.ringStrokeThin, t)!,
      outlineWidth: lerpDouble(outlineWidth, other.outlineWidth, t)!,
      selectedOutlineWidth: lerpDouble(
        selectedOutlineWidth,
        other.selectedOutlineWidth,
        t,
      )!,
    );
  }
}

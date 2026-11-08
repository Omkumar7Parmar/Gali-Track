import 'package:flutter/material.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';

/// A big, touch-friendly number picker: minus and plus buttons around the
/// value, with a slider underneath for big jumps.
///
/// It only reports the value the user asked for; the view model snaps and
/// clamps it, so the shown value is always one the app can save.
class ValueAdjuster extends StatelessWidget {
  const ValueAdjuster({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.formatValue,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double value;
  final double min;
  final double max;

  /// How much one tap on minus or plus changes the value.
  final double step;

  /// Turns a value into display text, such as "65.0 kg".
  final String Function(double value) formatValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final spacing = AppSpacing.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: textTheme.titleMedium),
        SizedBox(height: spacing.xs),
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: l10n.decreaseValue(label),
              onPressed: value <= min ? null : () => onChanged(value - step),
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Text(
                formatValue(value),
                textAlign: TextAlign.center,
                style: textTheme.displaySmall,
              ),
            ),
            IconButton.filledTonal(
              tooltip: l10n.increaseValue(label),
              onPressed: value >= max ? null : () => onChanged(value + step),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) / step).round(),
          semanticFormatterCallback: formatValue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

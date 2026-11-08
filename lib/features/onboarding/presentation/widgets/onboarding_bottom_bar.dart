import 'package:flutter/material.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/page_dots.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';

/// Page dots plus Back and Next buttons under the onboarding pages.
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    required this.page,
    required this.pageCount,
    required this.isLastPage,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final int page;
  final int pageCount;
  final bool isLastPage;
  final bool isSaving;

  /// Null on the first page, which hides the Back button.
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    final back = onBack;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.lg,
        spacing.sm,
        spacing.lg,
        spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PageDots(current: page, count: pageCount),
          SizedBox(height: spacing.md),
          // Each button gets up to half the width and keeps to its own edge,
          // so a long label at a large text size wraps instead of overflowing.
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: back == null
                      ? null
                      : TextButton(
                          onPressed: back,
                          child: Text(l10n.actionBack),
                        ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: isSaving ? null : onNext,
                    child: Text(
                      isLastPage ? l10n.actionStartWalking : l10n.actionNext,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

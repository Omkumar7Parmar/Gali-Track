import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_notifier.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/goal_page.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/onboarding_bottom_bar.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/profile_page.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/theme_page.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/welcome_page.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_motion.dart';
import 'package:galitrack/ui/failure_message.dart';
import 'package:galitrack/ui/save_status.dart';

/// First-launch flow: welcome, profile, goal and theme, one page each.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 4;

  // Which page is showing is short-lived UI state, so it stays in the widget.
  final _pageController = PageController();
  int _page = 0;

  bool get _isLastPage => _page == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final motion = AppMotion.of(context);
    final duration = resolveMotion(context, motion.medium);
    if (duration == Duration.zero) {
      _pageController.jumpToPage(page);
    } else {
      unawaited(
        _pageController.animateToPage(
          page,
          duration: duration,
          curve: motion.standard,
        ),
      );
    }
  }

  void _onNext() {
    if (_isLastPage) {
      ref.read(onboardingNotifierProvider.notifier).finish();
    } else {
      _goToPage(_page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingNotifierProvider.select((state) => state.saveStatus), (
      _,
      status,
    ) {
      if (status case SaveFailed(:final failure)) {
        final message = failureMessage(AppLocalizations.of(context), failure);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    final isSaving = ref.watch(
      onboardingNotifierProvider.select((state) => state.isSaving),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                children: const [
                  WelcomePage(),
                  ProfilePage(),
                  GoalPage(),
                  ThemePage(),
                ],
              ),
            ),
            OnboardingBottomBar(
              page: _page,
              pageCount: _pageCount,
              isLastPage: _isLastPage,
              isSaving: isSaving,
              onBack: _page == 0 ? null : () => _goToPage(_page - 1),
              onNext: _onNext,
            ),
          ],
        ),
      ),
    );
  }
}

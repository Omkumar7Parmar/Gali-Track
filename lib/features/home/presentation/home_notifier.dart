import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/clock_provider.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/providers.dart';
import 'package:galitrack/features/home/presentation/home_state.dart';

/// The home screen's view model.
final StreamNotifierProvider<HomeNotifier, HomeState> homeNotifierProvider =
    StreamNotifierProvider.autoDispose<HomeNotifier, HomeState>(
      HomeNotifier.new,
    );

/// Follows today's goal from the database.
///
/// Walks arrive in Week 2; until then today's steps, distance and streak
/// are zero.
class HomeNotifier extends StreamNotifier<HomeState> {
  @override
  Stream<HomeState> build() {
    final today = CalendarDay.of(ref.watch(clockProvider).now());
    return ref
        .watch(goalRepositoryProvider)
        .watchGoalOn(today)
        .map(
          (goal) => HomeState(
            // Onboarding always saves a goal, so the fallback is just a guard.
            goal: goal ?? DailyGoal.suggested,
            stepsToday: 0,
            distanceToday: const Meters(0),
            streakDays: 0,
          ),
        );
  }
}

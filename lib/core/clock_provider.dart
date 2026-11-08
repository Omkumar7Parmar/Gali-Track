import 'package:clock/clock.dart';
import 'package:riverpod/riverpod.dart';

/// The single source of "now" for the whole app.
///
/// Code reads `ref.read(clockProvider).now()` instead of `DateTime.now()`,
/// so tests can freeze time with `clockProvider.overrideWithValue(
/// Clock.fixed(...))`.
final clockProvider = Provider<Clock>((ref) => const Clock());

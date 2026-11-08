import 'package:riverpod/riverpod.dart';

/// The app's local diagnostic log. Nothing is ever sent off the phone.
///
/// The live implementation writes to a small file in app storage; tests
/// override [appLogProvider] with a fake that records calls.
abstract interface class AppLog {
  /// Records an error with its stack trace under a stable [code].
  void error(String code, Object error, StackTrace stackTrace);

  /// Records a breadcrumb, such as `app.started`, to give errors context.
  void info(String event);
}

/// Throws until bootstrap() overrides it, so a missing wiring fails loudly.
final appLogProvider = Provider<AppLog>(
  (ref) =>
      throw UnimplementedError('appLogProvider is overridden in bootstrap()'),
);

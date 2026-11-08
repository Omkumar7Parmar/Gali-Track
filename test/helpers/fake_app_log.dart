import 'package:galitrack/core/app_log.dart';

/// Records log calls so tests can assert a failure was logged.
final class FakeAppLog implements AppLog {
  /// The `code` of every error logged, in order.
  final List<String> errorCodes = [];

  /// Every breadcrumb logged, in order.
  final List<String> events = [];

  @override
  void error(String code, Object error, StackTrace stackTrace) =>
      errorCodes.add(code);

  @override
  void info(String event) => events.add(event);
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:galitrack/core/app_log.dart';

/// Installs the app's two global error handlers. Call before anything else
/// that can throw.
///
/// Expected failures never get here: they travel as `Result` values. Only
/// bugs and unrecoverable errors do. There is deliberately no
/// `runZonedGuarded`: these two handlers cover every path.
void installErrorHandlers(AppLog log) {
  // Errors in build, layout and paint.
  FlutterError.onError = (details) {
    try {
      FlutterError.presentError(details);
      log.error(
        'flutter.framework',
        details.exception,
        details.stack ?? StackTrace.empty,
      );
    } on Object catch (_) {
      // An error handler must never throw: that would re-enter this handler.
    }
  };

  // Uncaught async errors outside the framework.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    try {
      // Riverpod wraps provider errors; log the real cause, not the wrapper.
      if (error is ProviderException) {
        log.error('platform.uncaught', error.exception, error.stackTrace);
      } else {
        log.error('platform.uncaught', error, stackTrace);
      }
    } on Object catch (_) {
      // An error handler must never throw: that would re-enter this handler.
    }
    // Always true: false hands the error to the engine, which may kill the app.
    return true;
  };
}

import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/core/failure.dart';
import 'package:galitrack/core/result.dart';

/// Runs a database [write] and turns any exception into a typed failure.
///
/// The original error and stack are logged first, then [StorageWriteFailed]
/// is returned, so a database exception never reaches the UI.
Future<Result<void, StorageFailure>> guardedWrite(
  AppLog log,
  String operation,
  Future<void> Function() write,
) async {
  try {
    await write();
    return const Ok(null);
  } on Exception catch (error, stackTrace) {
    log.error(operation, error, stackTrace);
    return Err(StorageWriteFailed(operation));
  }
}

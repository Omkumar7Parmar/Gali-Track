import 'package:galitrack/core/failure.dart';

/// Where a save started from a screen stands. One value instead of loose
/// `isSaving` / `error` flags, so impossible combinations can't happen.
sealed class SaveStatus {
  const SaveStatus();
}

/// Nothing is being saved and the last save, if any, succeeded.
final class SaveIdle extends SaveStatus {
  const SaveIdle();
}

/// A save is in progress.
final class SaveInProgress extends SaveStatus {
  const SaveInProgress();
}

/// The last save failed. Each failure is a new instance, so the screen shows
/// the message again even if the same save fails twice.
final class SaveFailed extends SaveStatus {
  const SaveFailed(this.failure);

  final StorageFailure failure;
}

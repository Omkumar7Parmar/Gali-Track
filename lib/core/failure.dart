/// Base type for every expected, recoverable failure.
///
/// A failure carries a stable [code] and typed fields, never a user-facing
/// message: the presentation layer turns the code into localized text.
sealed class Failure {
  const Failure();

  /// A stable identifier, for example `storage.write_failed`.
  String get code;
}

/// Failures from the on-device database.
sealed class StorageFailure extends Failure {
  const StorageFailure();
}

/// A write to the database did not commit; nothing was changed.
final class StorageWriteFailed extends StorageFailure {
  const StorageWriteFailed(this.operation);

  /// Which repository operation failed, for logs and tests.
  final String operation;

  @override
  String get code => 'storage.write_failed';
}

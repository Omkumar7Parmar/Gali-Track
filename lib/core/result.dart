import 'package:galitrack/core/failure.dart';

/// The outcome of an operation that can fail for an expected reason.
///
/// Repositories return a [Result] instead of throwing, and callers `switch`
/// on it. Because [Result] is sealed, the compiler insists both [Ok] and
/// [Err] are handled.
sealed class Result<T, F extends Failure> {
  const Result();
}

/// The operation succeeded with [value].
final class Ok<T, F extends Failure> extends Result<T, F> {
  const Ok(this.value);

  final T value;
}

/// The operation failed with [failure].
final class Err<T, F extends Failure> extends Result<T, F> {
  const Err(this.failure);

  final F failure;
}

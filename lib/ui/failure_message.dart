import 'package:galitrack/core/failure.dart';
import 'package:galitrack/l10n/app_localizations.dart';

/// The user-facing message for [failure].
///
/// No `default:` case: adding a new failure type is a compile error here
/// until it gets a message.
String failureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      StorageWriteFailed() => l10n.errorSaveFailed,
    };

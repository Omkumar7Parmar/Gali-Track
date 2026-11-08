import 'package:drift_flutter/drift_flutter.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:path_provider/path_provider.dart';

/// Opens the database file in app-private storage.
///
/// drift_flutter runs SQLite on a background isolate, so queries never block
/// the UI. The file is created on the first query, not here.
AppDatabase openAppDatabase() {
  return AppDatabase(
    driftDatabase(
      name: 'galitrack',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );
}

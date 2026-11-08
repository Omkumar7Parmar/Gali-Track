import 'package:drift/drift.dart';

/// App-wide settings. Always exactly one row, with id 1, seeded on create.
///
/// The CHECK limits mirror `UserProfile` and `ThemePreference` in
/// lib/core/models; test/data/schema_constraints_test.dart keeps them in
/// step. They are table constraints written in SQL, which also keeps the
/// column getters free of self-references.
@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer()();

  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  TextColumn get themePreference =>
      text().withDefault(const Constant('system'))();

  IntColumn get weightGrams => integer().nullable()();

  IntColumn get heightCentimeters => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (id = 1)',
    "CHECK (theme_preference IN ('light', 'dark', 'system'))",
    'CHECK (weight_grams BETWEEN 25000 AND 250000)',
    'CHECK (height_centimeters BETWEEN 100 AND 250)',
    // Onboarding can't be marked done without the weight it collects.
    'CHECK (onboarding_completed = 0 OR weight_grams IS NOT NULL)',
  ];

  @override
  bool get isStrict => true;
}

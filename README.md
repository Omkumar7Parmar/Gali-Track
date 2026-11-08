# GaliTrack

[![ci](https://github.com/Omkumar7Parmar/Gali-Track/actions/workflows/ci.yml/badge.svg)](https://github.com/Omkumar7Parmar/Gali-Track/actions/workflows/ci.yml)

A privacy-first walking tracker for Indian streets, from wide roads to the
narrowest galis. Built with Flutter and OpenStreetMap. Everything runs on the
phone: no account, no backend, no cloud.

**Status:** Week 1 of 6 (foundation). Onboarding, theme, settings and the
Today screen work; walk tracking arrives in Week 2. See the
[technical plan](docs/TECHNICAL_PLAN.md).

## Running it

Generated code is not committed, so generate it once after cloning and again
after changing a database table or a string:

```bash
flutter pub get
dart run build_runner build
flutter run
```

## Checks

The same checks CI runs on every push:

```bash
dart format --output=none --set-exit-if-changed $(git ls-files '*.dart')
flutter analyze --fatal-infos --fatal-warnings
flutter test --test-randomize-ordering-seed random
```

## How it's built

- **Flutter + Riverpod 3** for state and dependency injection
- **Drift (SQLite)** as the single on-device source of truth, with STRICT
  tables and CHECK constraints that mirror the app's limits
- **go_router** with a pure, tested onboarding guard
- **Material 3** with hand-authored light and dark colour schemes, every
  colour pair tested for WCAG AA contrast
- Feature-first folders: `lib/core` (pure Dart), `lib/data` (the only layer
  that touches the database), `lib/features/*`, `lib/theme`, `lib/routing`

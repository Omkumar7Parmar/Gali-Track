# GaliTrack — Technical Plan (v1)

A privacy-first walking tracker for Indian streets. Built with Flutter and OpenStreetMap,
runs entirely on the phone, no accounts, no backend, ₹0 running cost.

- **Package name:** `com.omkumar.galitrack` (permanent once published)
- **Platform:** Android first (iOS later)
- **Language:** English
- **Repo:** https://github.com/Omkumar7Parmar/Gali-Track

---

## 1. Decisions so far

| Topic | Decision |
|---|---|
| Goal | Resume + GitHub + Play Store release, then move on |
| Accounts | None. No login, no cloud |
| Data | Walks stay on the phone. Export/backup (GPX) is post-v1 |
| Offline | Record with no internet + reuse map tiles already seen (levels A + B) |
| Map | OpenStreetMap's public tile server, background map only. No snapping or routing in v1 |
| State management | Riverpod |
| Daily goal | Steps by default; user can switch to km, or track both |
| Design | Google Fit style, more playful. Light/dark chosen at onboarding with a live preview |
| Test device | OnePlus Nord CE 3 (OxygenOS, aggressive battery saver) |

## 2. Open questions (defaults in use until answered)

| # | Question | Default |
|---|---|---|
| 1 | Steps: count only during recorded walks, or all day? | Only during walks. All-day counting needs a service running all day and costs battery |
| 2 | With both goals on, does a day count for the streak when you hit one goal, or only both? | Only when both are hit |
| 3 | Dark-mode map: darkened OSM tiles (free, simple), or a real dark map style from OpenFreeMap (nicer, but needs a vector-map add-on)? | Darkened OSM tiles in v1 |
| 4 | Add "Follow phone" next to Light and Dark in Settings? | Yes, in Settings only (built in Week 1). Onboarding stays a light/dark choice |

---

## 3. v1 feature list

**Onboarding (first launch only)**
1. Welcome screens: what the app does and its privacy promise
2. Profile: weight (needed for calories), height (optional, used to estimate stride length)
3. Goal setup: steps, km, or both, with target values
4. Theme picker: live preview of light and dark, user taps one

**Home dashboard**
- Today's progress ring(s) for the chosen goal(s)
- Current streak (days in a row the goal was met)
- This week at a glance
- Big "Start walk" button

**Live tracking**
- The first tap on Start asks for permissions, each with a one-line reason: location (needed),
  physical activity (steps), notifications (shows the tracking notification). Android's guidance
  is to ask at the moment a feature needs it, not during onboarding
- If a permission was denied permanently, explain how to turn it on in Settings
- Map with your route drawn as you walk
- Distance, duration, pace, steps, calories updating live
- Pause / resume / stop. No straight line is drawn across a pause
- Keeps tracking with the screen off and the phone in a pocket. The notification shows live
  distance and time
- If the phone kills the app mid-walk, the recorded part is kept; on next open the user can
  save it or carry on

**After a walk**
- Summary: map, stats, save or discard

**History and stats**
- List of past walks, newest first
- Walk detail: route map + stats
- Weekly/monthly charts for distance and steps
- Delete a walk

**Settings**
- Edit profile, goals and theme (Light / Dark / Follow phone)
- "Keep tracking reliable" help page (see 8.1)
- About, privacy policy, open-source licences, OSM attribution, "Report a map issue" link
  (https://www.openstreetmap.org/fixthemap)

**Post-v1 ideas:** GPX export/backup, download an area for offline maps (not allowed on OSM's
server; see section 5), auto-pause, achievements/badges, Hindi, iOS, all-day step counting.

---

## 4. Packages

Versions get pinned to the latest stable at setup time.

| Need | Package | Notes |
|---|---|---|
| State | `flutter_riverpod` | Plain `Notifier`/`AsyncNotifier` first, no code generation, so the patterns stay visible while learning |
| Navigation | `go_router` | Onboarding redirect, nested routes |
| Map | `flutter_map` (v8.2 or later) + `latlong2` | Built-in tile cache is on by default on Android (1 GB soft limit, follows the server's cache headers), so no caching plugin is needed |
| GPS | `geolocator` | Has an Android foreground-service option built in |
| Background fallback | `flutter_foreground_task` | Only if geolocator's built-in service gets killed on OxygenOS |
| Steps | `pedometer` | Uses the hardware step-counter sensor |
| Permissions | `permission_handler` | Location, activity recognition, notifications; `openAppSettings()` for the battery help page |
| Database | `drift` + `drift_flutter` (SQLite) | Settings, goals, walks, track points. Typed queries and migrations. Capped below 2.35 until the next Flutter upgrade (2.35 needs a newer `meta` than Flutter 3.41.2 ships) |
| Time | `clock` | The one source of "now", so tests can freeze time |
| Charts | `fl_chart` | Weekly/monthly stats |
| Lints | `very_good_analysis` (pinned) + `riverpod_lint` plugin | Strict rules; silent-bug lints promoted to errors |

Not using Hive or Isar: both have had maintenance problems; Drift is actively maintained
and SQLite suits a table of thousands of GPS points. Not using `shared_preferences` either:
settings live in the same database, so there is one store, one backup and the theme is
read before the first frame.

---

## 5. Map tiles: the rules

OSM's tile usage policy allows apps, on these conditions:

- **Identify the app.** Set `userAgentPackageName: 'com.omkumar.galitrack'` on the `TileLayer`.
  Requests with a generic identifier (like `com.example...`) get a "blocked" tile instead of the map.
- **Cache tiles** as the server's headers say. flutter_map v8.2+ does this by default.
- **Keep "© OpenStreetMap contributors" visible** on the map (`RichAttributionWidget`).
- **No bulk downloading** and no "save this area for offline" feature on OSM's server.

OSM runs on donations, gives no guarantee, and can block traffic without notice. So the tile
URL lives in one config file (in `lib/services/`) and switching provider is a one-line change.

**Backup providers** (free plans, checked November 2026):

| Provider | Free plan | Catch |
|---|---|---|
| OpenFreeMap | No limits, commercial use allowed, has a dark style, allows small offline downloads (up to 3,000 tiles or 50 MB each) | Vector tiles only: needs a vector-rendering add-on for flutter_map |
| Stadia Maps | 200,000 credits/month (about 200k raster tiles) | Non-commercial use only |
| MapTiler | 100,000 requests/month, no card needed | Pauses until next month when the quota runs out; shows a MapTiler logo |
| Thunderforest | 150,000 tiles/month (Hobby plan) | Bulk downloading only on paid plans |

**Dark mode:** OSM has no dark style. v1 darkens the tiles with a colour filter through
`TileLayer`'s `tileBuilder` (see open question 3).

**Privacy, stated honestly:** map tiles are the only data that leaves the phone. The tile server
sees the phone's IP address and which map area is loaded. The privacy policy says exactly that,
rather than claiming nothing ever leaves the phone.

---

## 6. Architecture

Feature-first folders over a strict downward-only layering. Pure maths (distance, filtering,
calories, streaks) is plain Dart with no Flutter imports, so it is easy to unit-test. A source
policy test (test/policy/) fails the build if a layer imports the wrong way.

```
lib/
  main.dart                 # entry point: calls bootstrap()
  bootstrap.dart            # composition root: log, error handlers, open DB, runApp
  app.dart                  # MaterialApp.router, themes
  app_settings.dart         # app-wide settings state (theme, onboarding gate)
  core/                     # pure Dart: Result/Failure, units, CalendarDay, models, clock
  data/                     # the ONLY layer that imports Drift
    db/                     #   database, tables, connection
    daos/                   #   single-table queries
    mappers/                #   row <-> value type
    repositories/           #   the single read/write path, returns Result
  services/                 # side effects: diagnostics log, error handlers (later: GPS, steps)
  theme/                    # tokens -> ColorScheme -> ThemeData; the only home of raw colours
  ui/                       # widgets shared by features (progress ring, value picker)
  routing/                  # the one GoRouter, routes, pure onboarding guard
  l10n/                     # app_en.arb (strings); generated code beside it
  features/
    onboarding/presentation/
    home/presentation/
    settings/presentation/
    tracking/               # Week 2
    history/                # Week 3
    stats/                  # Week 4
test/
  core/ data/ features/ routing/ theme/ policy/
  app_flow_test.dart        # acceptance: onboarding -> Today, settings -> theme
```

**How live tracking flows**

```
GPS (geolocator stream) ──► GPS filter ──► accepted point ──► save to DB
                                                    │
Step sensor (pedometer) ─────────────────────────────┤
                                                    ▼
                                    TrackingController (Riverpod)
                                     distance / time / pace / steps / kcal
                                                    │
                                    UI: map polyline + stats panel
```

- Every point is written to the database as it arrives, and the walk's running totals are saved
  every ~10 seconds. If OxygenOS kills the app mid-walk, at most a few seconds are lost.
- Times are stored in UTC. "Today", streaks and charts use the phone's local time, and a walk
  counts on the day it started.

---

## 7. Data model

Storage rules: every table is STRICT, limits are CHECK constraints that mirror the Dart
constants (a test keeps them in step), instants are UTC epoch milliseconds, a local calendar
day is a whole number of days since 1970-01-01, and quantities are integers of an SI unit.
The schema stays at version 1 until the first Play upload; after that every change is a
migration with a test.

**app_settings** (built in Week 1, exactly one row)

| Column | Type | Notes |
|---|---|---|
| id | int | always 1 |
| onboarding_completed | bool | can't be true without a weight |
| theme_preference | text | light / dark / system |
| weight_grams | int, nullable | 25–250 kg |
| height_centimeters | int, nullable | 100–250 cm, optional |

**goal_history** (built in Week 1)

| Column | Type | Notes |
|---|---|---|
| id | int | primary key |
| effective_from_day | int, unique | local day the goal starts; a second change that day replaces it |
| goal_type | text | steps / distance / both |
| step_target | int | 1,000–30,000; kept even when the type is distance |
| distance_target_meters | int | 500–30,000 m; kept even when the type is steps |

Streaks judge each day by the goal in force that day, so changing a goal never breaks or
rewrites past days.

**walks** (Week 2)

| Column | Type | Notes |
|---|---|---|
| id | int | primary key |
| started_at_utc_ms | int | |
| started_on_day | int | the local day the walk counts towards |
| ended_at_utc_ms | int, nullable | null = still in progress, or interrupted (used for crash recovery) |
| distance_meters | int | from accepted points only |
| moving_time_ms | int | excludes paused time |
| steps | int | |
| calories_kcal | int | estimate, using the weight at the time of the walk |

**track_points** (Week 2)

| Column | Type | Notes |
|---|---|---|
| id | int | primary key |
| walk_id | int | foreign key → walks, deleted with the walk |
| segment | int | starts at 0, goes up by one after each pause. Distance is summed only within a segment, and the map draws each segment as its own line |
| recorded_at_utc_ms | int | |
| latitude_e7, longitude_e7 | int | degrees × 10⁷, the same integer format OpenStreetMap uses |
| accuracy_m | real | GPS-reported accuracy (a sensor reading, so it stays real) |
| speed_mps | real, nullable | |
| accepted | bool | false = rejected by the filter. Kept so filter accuracy can be measured |

---

## 8. The two "challenges" (build and measure them)

These are the resume talking points, so each needs real numbers.

### 8.1 Staying alive on OxygenOS
- Tracking runs as an Android **foreground service of type `location`**, started when the
  user taps Start while the app is open. The manifest declares `FOREGROUND_SERVICE` and
  `FOREGROUND_SERVICE_LOCATION` (needed on Android 14+).
- So the app does **not** need `ACCESS_BACKGROUND_LOCATION`. That permission triggers a strict
  Play review with a demo video and is often rejected.
- Don't ask for the direct battery-optimisation exemption (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`).
  Google Play limits it to a narrow set of apps. Instead:
  - Before the first walk, show a short "Keep tracking reliable" screen with a button to the
    app's settings page. On OxygenOS the switch is usually under Battery usage → Allow
    background activity.
  - Show it again if a walk has a gap (no GPS point for over a minute while tracking).
  - Reference for OnePlus quirks: https://dontkillmyapp.com/oneplus
- **Measure:** walk 30+ minutes with the phone locked in a pocket on the Nord CE 3, check for
  gaps in the recorded points, and note battery % used per hour.

### 8.2 Filtering GPS noise
Steps, in order:
1. Drop points with accuracy worse than ~25 m.
2. Drop jumps that imply an impossible walking speed (for example over ~4 m/s).
3. Ignore tiny moves under a few metres while standing still (stops distance creeping up).
4. Optionally smooth the remaining points with a simple Kalman filter.

- Distance = sum of the haversine distances between accepted points, within each segment.
- Every point keeps its `accepted` flag, so raw and filtered distance can be compared on the
  same walk.
- **Measure:** walk a known route (for example a measured 1 km loop), compare raw distance vs
  filtered distance vs the true distance.

### Steps and calories
- **Steps:** `pedometer` reads the hardware step counter. Steps during a pause don't count.
  If a phone has no step sensor, estimate steps from distance and stride length
  (roughly 0.41 × height).
- **Calories:** `kcal = MET × weight_kg × hours`, where MET comes from walking speed
  (about 2.8 slow ≈3 km/h, 3.5 normal ≈5 km/h, 5.0 brisk ≈6.5 km/h). Shown as an estimate.

---

## 9. Testing and quality

- **Unit tests** (pure Dart): haversine, GPS filter, calories, streaks.
- **Replay tests:** a debug-only option saves a walk's raw points as a JSON file. Real walks
  become test fixtures and give the raw-vs-filtered numbers for the README.
- **Widget tests** for the main screens. The old counter test is replaced in Week 1.
- **GitHub Actions** on every push: format check, `flutter analyze`, `flutter test`. A green
  badge on the README is a cheap portfolio signal.
- **Crash reports:** Play Console's Android vitals. No crash-reporting SDK, which keeps the
  privacy promise.

---

## 10. Play Store checklist

- [ ] Create a Play Console personal account (one-time US$25 fee; identity verification can take
      a few days). Week 1, your action
- [ ] Change package name to `com.omkumar.galitrack` before the first upload; rename the Dart
      package to `galitrack`
- [ ] App name, icon, splash screen
- [ ] Use Play App Signing; keep the upload key outside git (already in `.gitignore`) and backed up
- [ ] Privacy policy page (for example GitHub Pages): walks stay on the device; the map provider
      sees the IP address and map area loaded
- [ ] App content forms in Play Console:
  - [ ] Data safety
  - [ ] Content rating
  - [ ] Health apps declaration (required for every app, including test tracks): "Activity and fitness"
  - [ ] Foreground-service declaration (location type): needs a link to a short video showing
        how a user starts a walk
- [ ] Target SDK: Flutter 3.41 defaults to API 36. Keep Flutter updated so it meets Play's yearly
      target-API rule
- [ ] Release build supports 16 KB memory pages (check in Play Console's App bundle explorer);
      keep Flutter and plugins up to date
- [ ] OSM: unique app identifier, visible attribution, contact email on the store listing
- [ ] **Closed test: at least 12 testers opted in continuously for 14 days.** Testers who drop out
      don't count, so recruit about 20. Then apply for production (review usually takes up to
      7 days)
- [ ] Store listing: screenshots (light + dark), short and full description

---

## 11. Build order (about 6 weeks to public)

The 14-day closed test starts at the end of Week 3 and runs while Weeks 4–5 are built.
New builds go to testers as they are ready.

| Week | Focus | Done when |
|---|---|---|
| 1 ✅ | Foundation: package rename, packages, CI, theme, router, database, settings, onboarding with theme preview. **You:** create the Play Console account and start gathering testers | Fresh install goes through onboarding and lands on Today (proven by test/app_flow_test.dart) |
| 2 | Tracking core: permissions, GPS stream, foreground service, GPS filter + tests, live map, saving points, pause segments, crash recovery | A pocket walk on the Nord CE 3 records a clean route with the screen off |
| 3 | Steps, calories, walk summary, history list, walk detail. Privacy policy, Play Console forms, foreground-service video. Upload to closed testing | 12+ testers opted in |
| 4 | Home dashboard, goals, streaks, stats charts | Goals and streaks work; update sent to testers |
| 5 | Polish (light/dark, empty and error states, large text, screen reader labels), icon, splash, store listing, final device testing | 14 days done; production access requested |
| 6 | Production review. README with the challenge write-ups and measured numbers | Live on the Play Store |

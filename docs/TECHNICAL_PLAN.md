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
| Data | Stays on the phone. Export/backup (GPX) is post-v1 |
| Offline | Record with no internet + cache map tiles already seen (levels A + B) |
| OSM use | Background map only. No snapping or routing in v1 |
| State management | Riverpod |
| Daily goal | Steps by default; user can switch to km, or track both |
| Design | Google Fit style, more playful. Light/dark chosen at onboarding with a live preview |
| Test device | OnePlus Nord CE 3 (OxygenOS, aggressive battery saver) |

**Assumed default (change if you disagree):** steps are counted only during recorded walks.
The daily step goal is the sum of today's walks. Counting all-day steps in the background
is a much bigger battery and permission problem, so it waits for later.

---

## 2. v1 feature list

**Onboarding (first launch only)**
1. Welcome screens explaining the app and its privacy promise
2. Profile: weight (needed), height (optional)
3. Goal setup: steps, km, or both, with target values
4. Theme picker: live preview of light and dark, user taps one
5. Permissions explained before asking: location, physical activity, notifications

**Home dashboard**
- Today's progress ring(s) for the chosen goal(s)
- Current streak (days in a row the goal was met)
- This week at a glance
- Big "Start walk" button

**Live tracking**
- Map with your route drawn as you walk
- Distance, duration, pace, steps, calories updating live
- Pause / resume / stop
- Keeps tracking with the screen off and the phone in a pocket (persistent notification)
- Survives the app being killed: the walk resumes or can be saved on next open

**After a walk**
- Summary: map, stats, save or discard

**History and stats**
- List of past walks, newest first
- Walk detail: route map + stats
- Weekly/monthly charts for distance and steps
- Delete a walk

**Settings**
- Edit profile, goals and theme
- About, privacy policy, open-source licences, OSM attribution

**Post-v1 ideas:** GPX export/backup, download an area for offline maps, auto-pause,
achievements/badges, Hindi, iOS, all-day step counting.

---

## 3. Packages

Versions get pinned to the latest stable at setup time.

| Need | Package | Notes |
|---|---|---|
| State | `flutter_riverpod` | Plain `Notifier`/`AsyncNotifier` first, no code generation, so the patterns stay visible while learning |
| Navigation | `go_router` | Onboarding redirect, nested routes |
| Map | `flutter_map` + `latlong2` | OSM tiles. Check its built-in tile caching first; check the licence of any caching plugin before adding it (some are GPL) |
| GPS | `geolocator` | Has an Android foreground-service option built in |
| Background fallback | `flutter_foreground_task` | Only if geolocator's built-in service gets killed on OxygenOS |
| Steps | `pedometer` | Uses the hardware step-counter sensor |
| Permissions | `permission_handler` | Activity recognition, notifications, battery-optimisation prompt |
| Database | `drift` (SQLite) | Walks and track points. Typed queries and migrations |
| Small settings | `shared_preferences` | Theme, onboarding-done flag, goals |
| Charts | `fl_chart` | Weekly/monthly stats |

Not using Hive or Isar: both have had maintenance problems; Drift is actively maintained
and SQLite suits a table of thousands of GPS points.

---

## 4. Architecture

Feature-first folders. Each feature has the UI, its Riverpod providers, and any logic it owns.
Pure maths (distance, filtering, calories) is plain Dart with no Flutter imports, so it is easy
to unit-test.

```
lib/
  main.dart                 # starts the app, sets up error logging
  app.dart                  # MaterialApp.router, themes
  core/
    theme/                  # colours, text styles, light + dark themes
    router/                 # go_router config, onboarding redirect
    database/               # Drift database, tables, migrations
    settings/               # shared_preferences wrapper + provider
    utils/                  # formatting (km, pace, duration)
  features/
    onboarding/
    home/
    tracking/
      domain/               # haversine, gps_filter, calories (pure Dart)
      data/                 # location + step services, walk repository
      presentation/         # live map screen, controls, summary
    history/
    stats/
    settings/
test/
  tracking/domain/          # unit tests for the maths
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

Every point is written to the database as it arrives, not only when the walk ends.
If OxygenOS kills the app mid-walk, nothing is lost and the walk can be recovered.

---

## 5. Data model

**walks**

| Column | Type | Notes |
|---|---|---|
| id | int | primary key |
| started_at | datetime (UTC) | |
| ended_at | datetime, nullable | null = walk still in progress (used for crash recovery) |
| distance_m | real | from accepted points only |
| moving_time_s | int | excludes paused time |
| steps | int | |
| calories_kcal | real | |

**track_points**

| Column | Type | Notes |
|---|---|---|
| id | int | primary key |
| walk_id | int | foreign key → walks |
| recorded_at | datetime (UTC) | |
| lat, lng | real | |
| accuracy_m | real | GPS-reported accuracy |
| speed_mps | real, nullable | |
| accepted | bool | false = rejected by the filter. Kept so filter accuracy can be measured |

**Settings (shared_preferences):** onboarding done, theme, weight, height, goal type,
step goal, km goal.

---

## 6. The two "challenges" (build and measure them)

These are the resume talking points, so each needs real numbers.

### 6.1 Staying alive on OxygenOS
- Tracking runs as an Android **foreground service of type `location`**, started when the
  user taps Start while the app is open.
- So the app does **not** need `ACCESS_BACKGROUND_LOCATION`. That permission triggers a strict
  Play review with a demo video and is often rejected.
- Ask the user to exclude the app from battery optimisation, with a short explanation of why.
- **Measure:** walk 30+ minutes with the phone locked in a pocket on the Nord CE 3, check for
  gaps in the recorded points, and note battery % used per hour.

### 6.2 Filtering GPS noise
Steps, in order:
1. Drop points with accuracy worse than ~25 m.
2. Drop jumps that imply an impossible walking speed (for example over ~4 m/s).
3. Ignore tiny moves under a few metres while standing still (stops distance creeping up).
4. Optionally smooth the remaining points with a simple Kalman filter.

- Distance = sum of the haversine distances between accepted points.
- All of this is pure Dart with unit tests built from real recorded walks.
- **Measure:** walk a known route (for example a measured 1 km loop), compare raw distance vs
  filtered distance vs the true distance.

### Calories
`kcal = MET × weight_kg × hours`, where MET comes from walking speed
(about 2.8 for slow, 3.5 for normal, 5.0 for brisk walking). Shown as an estimate.

---

## 7. Play Store checklist

- [ ] Change package name to `com.omkumar.galitrack` (before the first upload)
- [ ] App name, icon, splash screen
- [ ] Release signing key, stored outside git (already in `.gitignore`)
- [ ] Privacy policy page (for example GitHub Pages): "all data stays on your device"
- [ ] Play Console: data safety form, foreground-service (location) declaration, content rating
- [ ] OSM attribution visible on the map; real app identifier sent with tile requests
- [ ] **Closed test: 12 testers for 14 days** (needed for new personal accounts). Start
      collecting testers early
- [ ] Store listing: screenshots (light + dark), short and full description

---

## 8. Build order (about 5 weeks + 2 weeks of testing)

| Week | Focus | Done when |
|---|---|---|
| 1 | Foundation: package rename, packages, theme, router, database, settings, onboarding with theme preview | Fresh install goes through onboarding and lands on an empty home screen |
| 2 | Tracking core: permissions, GPS stream, foreground service, GPS filter + tests, live map, saving points, crash recovery | A pocket walk on the Nord CE 3 records a clean route with the screen off |
| 3 | Steps, calories, walk summary, history list, walk detail | Past walks can be browsed and opened |
| 4 | Home dashboard, goals, streaks, stats charts, polish, empty and error states | The app feels complete in light and dark |
| 5 | Release prep: icon, splash, privacy policy, signing, store listing, final device testing | Uploaded to closed testing |
| 6–7 | 14-day closed test; fix bugs; write README with the challenge write-ups and measurements | Production release |

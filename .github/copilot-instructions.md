# Copilot / AI agent instructions for this repo ✅

Short, actionable guidance to make an AI coding agent immediately productive.

## Big picture (what this app is)
- Single-screen Flutter devotional reader (`MaterialApp` in `lib/main.dart`).
- Content is CSV-driven: `assets/devotionals.csv` contains rows with columns: `Date, Verse, Devotional, Prayer`.
- Per-day notes and last-opened page are persisted locally using `shared_preferences` (see `_saveState`, `_loadLastState`).

## Key files & responsibilities 🔧
- `lib/main.dart` — entire app UI + logic: CSV loading (`_loadCSV`), persistence (`_saveState`, `_loadLastState`), navigation (`_navigateTo`), rendering and safety guards for missing columns.
- `assets/devotionals.csv` — canonical source of content. Row 0 is the CSV header; app uses rows 1..N for days.
- `pubspec.yaml` — declares asset and Dart SDK constraint (>=3.2.0 <4.0.0).

## Important project-specific conventions (must know) ⚠️
- Indexing: the CSV header occupies `listData[0]`. App uses 1-based day indices (default `currentIndex = 1`). When iterating the drawer, code does `itemCount = listData.length - 1` and `actualIndex = index + 1`.
- Persistence keys: notes are stored as `note_<index>` (e.g. `note_12`), and last page as `last_index`.
- Safety: code defensively accesses CSV columns (checks length before using an index) — follow this pattern when editing rendering logic to avoid RangeError.
- UI strings are hard-coded in Korean; there is no i18n/l10n setup.
- Performance tweak: `ListView.builder` uses `cacheExtent: 1000` to improve scrolling performance for many entries.

## Developer workflows (concrete commands) ▶️
- Install deps: `flutter pub get`.
- Run locally (mobile): `flutter run -d <device>` (e.g., `flutter run -d emulator-5554`).
- Run on web quickly: `flutter run -d chrome`.
- Build release: `flutter build apk` or `flutter build web` depending on target.
- Tests: `flutter test` (no tests currently in repo).
- Note: editing assets (CSV) requires a full app restart to pick up changes; stop and re-run the app (hot reload does not always refresh assets).

## Debugging tips specific to this repo 🐞
- CSV issues: check `assets/devotionals.csv` header and columns; multi-line cells are quoted (see file). The app catches CSV load errors and prints `CSV Load Error: <error>` via `debugPrint`.
- Persistence issues: use `debugPrint` or temporary debug UI to inspect `SharedPreferences` keys (`note_<index>` and `last_index`). On Android you can also use Device File Explorer or `adb` to inspect app data if needed.
- To validate persistence: enter a note, stop app, restart app — the same note should reappear for that day.

## How to add content / make changes 🛠️
- To add or edit devotionals, modify `assets/devotionals.csv`. Keep the header row (`Date,Verse,Devotional,Prayer`) and ensure quoted multi-line fields remain valid CSV.
- If adding a new asset path or file, update `pubspec.yaml` accordingly and run `flutter pub get`.

## Common PRs you might encounter / create
- Bugfix: guard CSV access when a row may miss columns — follow existing pattern in `build` (check `length` before indexing).
- Feature: if adding persistent settings (e.g., theme choice), store them in `SharedPreferences` with clear key names; currently theme toggling is in-memory only.

## Things NOT present (so don't assume them) ❌
- No CI workflows / GitHub Actions are included.
- No test suite exists; adding tests is welcome but not required right away.
- No localization / i18n support.

## Example references (quick lookups)
- CSV loading: `_loadCSV()` in `lib/main.dart` (uses `rootBundle.loadString` + `CsvToListConverter`).
- Save/load state: `_saveState(String noteValue)` and `_loadLastState()` in `lib/main.dart` (use `SharedPreferences`).
- Drawer indexing: `itemCount: listData.length - 1` and `actualIndex = index + 1`.

---
If anything here is unclear or you'd like additional detail (examples of tests, a sample CI workflow, or contributor checks), tell me which area to expand and I'll iterate. ✨

# MoodFlow

A Flutter mobile app for tracking your daily mood, keeping a short journal, and getting music recommendations that match how you feel. Built as a prototype with a clean purple/lavender design language and an in-memory data layer that powers live statistics.

> _"Choose your mood and get personalized music suggestions."_

---

## Highlights

- **4 fully interactive screens** wired through a custom bottom navigation bar (Home, History, Stats, Profile).
- **Live mood store** — every saved entry instantly updates the History list, the Stats charts, and the Profile counters via `ChangeNotifier`.
- **Daily journal** — write a few words alongside each mood entry; entries are timestamped automatically.
- **Music recommendations** — tap any music card to open a detail bottom sheet; tap the play button for a quick action.
- **Real analytics** — 7-day line chart, mood distribution percentages, and a current-streak calculator, all derived from your saved entries.
- **Swipe-to-delete** in History and a confirmation-protected "reset all" in Profile.

---

## Screens

### Home (`lib/main.dart` → `HomeScreen`)
The landing screen. Pick one of four moods (Calm, Happy, Melancholic, Energetic), optionally add a journal note, and hit **Save Mood** to record an entry. The header avatar jumps to the Profile tab; music cards open a detail sheet.

### History (`lib/history_screen.dart`)
A reverse-chronological list of every saved mood, each rendered as a colored card with mood-specific icon and a relative timestamp ("Bugün 14:32", "Dün 09:10", or full date). Swipe a card right-to-left to delete it. Empty state guides the user back to Home.

### Stats (`lib/stats_screen.dart`)
- **Weekly Mood Trend** — a smooth `fl_chart` line graph counting the number of entries you logged on each of the last 7 days.
- **Mood Distribution** — percentage breakdown of which moods you pick most.
- **Streak card** — counts how many consecutive days (ending today) include at least one entry.

### Profile (`lib/profile_screen.dart`)
- Gradient profile card with name and email.
- Stats tiles for total entries, current streak, and most-frequent mood.
- Settings rows (notifications, theme, help — currently demo SnackBars).
- **Reset all data** button with a confirmation dialog.

---

## Architecture

```
lib/
├── main.dart            # MaterialApp + MainScaffold (bottom nav) + HomeScreen
├── mood_store.dart      # In-memory MoodStore (singleton, ChangeNotifier)
├── history_screen.dart  # List of saved entries with swipe-to-delete
├── stats_screen.dart    # fl_chart line chart + distribution + streak
└── profile_screen.dart  # Profile, stats tiles, settings, reset
```

### State management
A single `MoodStore` singleton extends `ChangeNotifier` and exposes:

- `add(MoodEntry)` / `removeAt(int)` / `clear()`
- `entries` — read-only list, newest first
- `distributionPercent()` — `{ 'Calm': 42.0, … }`
- `mostFrequentMood()`
- `last7DaysCounts()` — `List<int>` of length 7, used as chart Y-values
- `currentStreak()` — consecutive days ending today

Each screen wraps its body in `AnimatedBuilder(animation: MoodStore.instance, …)`, so any change to the store re-renders every visible screen automatically — no Provider, Riverpod, or Bloc required for this prototype.

### Navigation
`MainScaffold` keeps a single `_currentIndex` and uses `IndexedStack` to keep all four pages mounted (so Home's selected mood and journal text persist while you visit other tabs). The bottom bar is a custom `Row` of `_NavItem`s, each an `InkWell` that calls back into the parent.

### Data persistence
Entries live **in memory only** — they're cleared when the app process is killed. Swap `mood_store.dart` for a `shared_preferences` (or Hive / Drift) implementation when you're ready to persist; the rest of the codebase doesn't need to change because every screen talks to the store through the same interface.

---

## Getting started

### Prerequisites
- Flutter SDK 3.10.3 or newer (`flutter --version`)
- Dart 3.x (bundled with Flutter)
- An iOS Simulator, Android emulator, or a physical device

### Run it

```bash
cd moodflow_app
flutter pub get
flutter run
```

To pick a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

### Build a release

```bash
flutter build apk           # Android
flutter build ios           # iOS (requires Xcode)
flutter build macos         # macOS desktop
```

---

## Dependencies

Defined in [`pubspec.yaml`](pubspec.yaml):

| Package | Purpose |
|---|---|
| `flutter` | Core SDK |
| `cupertino_icons` | iOS-style icon font |
| `fl_chart` ^0.68.0 | Line chart on the Stats screen |
| `flutter_lints` (dev) | Recommended lint rules |

Mood images and music cover art are loaded from Unsplash CDN URLs at runtime, so the app needs an internet connection on first launch to populate the imagery.

---

## Design tokens

The UI uses a small, consistent palette:

| Token | Hex | Used for |
|---|---|---|
| Background | `#FAF8FF` | Scaffold background |
| Primary purple | `#6B3FD6` | Active states, accents, chart line |
| Gradient | `#7C4DFF → #5E35B1` | Save button, profile card, streak card |
| Card border | `#EDE8FF` / `#E5DFFF` | Subtle outlines |
| Body text | `#171733` / `#22203A` | Headings & body |
| Muted text | `#6F6B80` / `#8D889A` | Hints, captions |

Per-mood accent colors live in `history_screen.dart` (`_moodColors`) — extend that map when you add new moods.

---

## Extending the app

A few easy next steps:

1. **Persistence** — replace the list inside `MoodStore` with a `shared_preferences`- or Hive-backed implementation. The public API can stay identical.
2. **Edit a journal entry** — add an `update(int index, MoodEntry)` method to the store and an edit action to the History card.
3. **Filter History by mood** — add a chip row above the list and filter `entries` before rendering.
4. **Real audio playback** — swap the play button's SnackBar for `just_audio` or `audioplayers` and feed the bottom sheet real track URLs.
5. **More moods** — add new entries to `kMoods` in `main.dart`, register a color in `_moodColors`, and pick an icon in `_moodIcons`.

---

## Project structure (full)

```
moodflow_app/
├── lib/                  # Dart source
├── android/              # Android shell
├── ios/                  # iOS shell
├── macos/ linux/ windows/ web/   # Desktop & web shells
├── test/                 # Unit/widget tests (placeholder)
├── pubspec.yaml          # Dependencies & assets
├── analysis_options.yaml # Lint config
└── README.md             # You are here
```

---

## License


# cinemapedia

A Flutter movie browser for **iOS and Android**. Discover what's playing, save what you want to
watch, and find where to stream it. All driven by [TMDB](https://www.themoviedb.org) for content
and a local [Drift](https://drift.simonbinder.eu) database for favourites — no account required.

---

## Quick start

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure TMDB credentials
cp .env.template .env
# Edit .env and set THE_MOVIE_DB_KEY (and optionally THE_MOVIE_DB_ACCESS_TOKEN)

# 3. Generate the Drift schema (only needed if you change database.dart)
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run -d <device-id>
flutter run -d "iPhone 17e"
flutter run -d <android-device-id>
```

Get a free TMDB key at <https://www.themoviedb.org/settings/api>. The `v3` API key (query parameter)
or `v4` read access token (Bearer header) both work.

## Features

- **Home**: Now playing, Top 10, Upcoming, Top rated — paginated horizontal lists
- **Search**: Debounced query against `/search/movie`, with the last 5 queries saved locally
- **Categories**: Browse by genre (TMDB genres)
- **Movie detail**: Poster hero, synopsis, genres, cast, watch providers by country, embedded
  YouTube trailer, similar movies
- **Actor detail**: Bio, profile, filmography
- **Favorites**: Local-only, Drift-backed, with Instagram-style heart animation, double-tap
  to-favorite on the movie poster, long-press to remove from the favourites list
- **Settings**: Light/Dark/System theme (reactive, persists immediately), language placeholder,
  clear search history, app version

## Architecture

Clean Architecture with three layers. Imports flow inward.

```
lib/
├── config/                  # cross-cutting wiring
│   ├── constants/           # env loader (TMDB keys)
│   ├── database/            # Drift schema + generated code
│   ├── router/              # go_router (one source of truth for navigation)
│   ├── storage/             # SharedPreferences wrapper
│   └── theme/               # design tokens + dual ThemeData + reactive theme mode
├── domain/                  # pure Dart — entities, abstract datasource/repo contracts
├── infrastructure/          # concrete impls — Dio datasources, mappers, repo impls
└── presentations/           # UI + Riverpod state
    ├── views/               # tab bodies (Home / Categories / Favorites)
    ├── screens/             # full routed pages
    ├── widgets/             # reusable widgets (shared + per-feature)
    ├── delegates/           # search delegate
    └── providers/           # Riverpod state, organised by feature
```

### Stack

| Concern | Choice | Why |
|---|---|---|
| State | `flutter_riverpod` | No BuildContext for reads, compile-safe providers |
| Navigation | `go_router` (path-param nested) | Declarative, deep-link friendly |
| HTTP | `dio` | Interceptors, easy `BaseOptions` for TMDB defaults |
| Local DB | `drift` | Type-safe SQL, codegen keeps DTOs honest |
| Design tokens | Hand-rolled (see `lib/config/theme/`) | One source of truth; designers can read `DESIGN.md` |

## Themes

cinemapedia ships **two themes** (Dark and Light), chosen at runtime via Settings. The design
system is documented in [DESIGN.md](DESIGN.md); the implementation is under `lib/config/theme/`.

Every widget that paints with a brand colour reads `context.colors` (an extension on `BuildContext`)
rather than importing `AppColors` directly. This keeps the colour theme-aware for free.

## Project rules

See [CLAUDE.md](CLAUDE.md) for the full ruleset. The short version:

- UI copy is Spanish (es-MX), code and comments are English
- Comments are one line, explain why, never what
- No abstraction with a single implementation; no config for values that never change
- Reuse-first: shared widgets → stdlib → existing deps → new code
- Theming from tokens — a hardcoded colour is a bug
- Definition of done: lint clean, file ≤ 300 lines (with documented deviations), rules respected,
  user commits

## Build

```bash
flutter build apk              # Android release build
flutter build ios              # iOS release build (requires signing on real device)
```

Both platforms are configured in `android/` and `ios/` respectively. The project deliberately
ships **without** web, macOS, Windows, or Linux platform folders.

## Useful scripts

```bash
flutter analyze                          # static analysis
dart format lib/                        # formatter
flutter pub outdated                     # check for newer dependency versions
dart run build_runner build              # regenerate Drift schema after edits
dart run flutter_launcher_icons          # regenerate app icons from assets/icon.png
dart run flutter_native_splash:create   # regenerate splash from assets/splash/
```

## Documentation

- [CLAUDE.md](CLAUDE.md) — project rules for AI agents and humans
- [DESIGN.md](DESIGN.md) — locked design system (colours, typography, motion, components)
- [Improve_design_functionaly.md](Improve_design_functionaly.md) — feature audit + phased roadmap
- [TMDB_features.md](TMDB_features.md) — TMDB API surface and feature proposal

## License

This project is not published. TMDB data is used under their
[terms of use](https://www.themoviedb.org/documentation/api/terms-of-use); artwork and metadata
remain the property of their respective rights holders.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Rules for working in this repository. **Follow them strictly.** If a rule blocks the task,
say so and stop — do not improvise around it.

Two companion documents, equally binding:
- [Improve_design_functionaly.md](Improve_design_functionaly.md) — audit + roadmap of pending
  improvements, by phase
- `DESIGN.md` — locked design system (created in phase 1; not yet on disk)

## Project

`cinemapedia` — Flutter movie browser for **iOS and Android only** (no web/desktop). TMDB API for
content, Drift for local favorites, Riverpod for state, go_router for nav.

- Flutter SDK: `^3.6.0`
- Branches: `main` (PRs) / `develop` (work)
- Org (Android): `com.example.cinemapedia` (rename in phase 0)
- No tests, no CI yet.

## Commands

```bash
# Setup: copy env template, fill in TMDB key + access token
cp .env.template .env

# Run
flutter pub get
flutter run                            # default device
flutter run -d "iPhone 17e"            # specific simulator
flutter run -d <android-device-id>     # android

# Analyze (lints via flutter_lints 6.x)
flutter analyze

# Format
dart format lib/

# Drift codegen (when database.dart schema changes)
dart run build_runner build --delete-conflicting-outputs

# Build (per platform — web/desktop folders were deleted, these are the only targets)
flutter build apk
flutter build ios

# App icon / splash regeneration (already configured in pubspec.yaml)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

`.env` is gitignored. `main()` calls `WidgetsFlutterBinding.ensureInitialized()` then
`dotenv.load(fileName: '.env')` before `runApp` — no env = crash on first network call.

## Architecture

Clean Architecture, three layers under `lib/`. Imports flow inward: `presentations` → `domain` ←
`infrastructure`.

```
lib/
├── config/
│   ├── constants/environment.dart   # reads THE_MOVIE_DB_KEY + THE_MOVIE_DB_ACCESS_TOKEN
│   ├── database/database.dart       # Drift schema (FavoriteMovies table) + AppDatabase
│   ├── database/database.g.dart     # GENERATED — do not edit; regenerate via build_runner
│   ├── router/app_router.dart       # go_router, see "Routes" below
│   ├── theme/                       # design tokens — populated in phase 1
│   └── helpers/human_formats.dart
├── domain/                          # pure Dart, no Flutter/IO imports
│   ├── entities/                    # Movie, Actor, ActorDetails, Genre, MovieVideos, WatchProviders
│   └── datasources/                 # abstract contracts, one per external system
│       ├── movies_datasource.dart
│       ├── actors_datasource.dart
│       ├── actor_details_datasource.dart
│       ├── genre_datasource.dart
│       ├── movie_videos_datasource.dart
│       ├── watch_providers_datasource.dart
│       └── local_storage_datasource.dart
├── repositories/                    # abstract contracts (parallel to domain/datasources/)
│   └── 7 files (movies, actors, actor_details, genre, movie_videos, watch_providers, localstorage)
├── infrastructure/                  # concrete impls
│   ├── datasources/                 # one per domain datasource: moviedb_* + local_storage_favoritedb
│   ├── mappers/                     # DTO → entity; movie_mapper handles MovieMovieDB + MovieDetails
│   ├── models/moviedb/              # DTOs (MovieMovieDB, MovieDetails, CreditsResponse, ActorCreditsResponse)
│   └── repositories/                # repo impls (renamed from "reporsitories" in phase 0)
└── presentations/
    ├── views/home/                  # HomeView, CategoriesView, FavoritesView (tab bodies)
    ├── screens/movies/              # HomeScreen (tab host), MovieScreen, ActorScreen, MoviesByGenreScreen
    ├── screens/loaders/full_screen_loader.dart
    ├── widgets/                     # shared/ + movies/ + actors/
    ├── delegates/search_movies_delegate.dart
    └── providers/                   # Riverpod, organized by feature:
        ├── movies/                  # 4 list providers + MoviesNotifier + family providers
        ├── genre/                   # genres grid
        ├── movie_videos/            # trailers
        ├── search/                  # search results
        └── favorites_localstorage/  # local DB-backed favorites
```

### Layer rules

- New external system (TMDB endpoint, local table, etc.) → add abstract to `domain/datasources/`,
  implementation to `infrastructure/datasources/`, abstract repo to `repositories/`, repo impl to
  `infrastructure/repositories/`, wire in `presentations/providers/<feature>/`.
- DI is constructor injection. New datasource: create provider in
  `presentations/providers/<feature>/`, pass datasource into repo, expose repo via `Provider`.
- `MoviesNotifier` is the universal paginated list notifier — reused by 4 lists + 2 family
  providers (`similarMoviesProvider(movieId)`, `moviesByGenreProvider(genreId)`). Has built-in
  `isLoading` guard + 300ms post-page delay.
- DB injection: `LocalStorageFavoriteDBDatasource` accepts `AppDatabase` via constructor
  (cleaned up in phase 0 — was inline before).
- Barrel files: `presentations/providers/providers.dart`, `widgets.dart`, `screens.dart`,
  `views/views.dart`. Add exports there when adding new modules.

## The two languages

Strictly enforced.

**Everything the user reads is in Spanish (es-MX, tuteo).** Labels, buttons, titles, hints,
validation messages, error messages, snackbars, tooltips, empty states, share text.
Exceptions: the product name (`cinemapedia`), and developer errors that only ever reach a log or
a debug console.

**Everything a developer reads is in English.**

- All code in English: class names, variables, methods, file names, folders.
- All comments in English.
- Comments are **short — one line**. Explain *why*, never *what*. If the code needs a paragraph
  to be understood, rewrite the code instead. No file headers, no doc blocks, no section
  banners, no commented-out code.

```dart
// Drift queries happen on the main isolate; pagination limits row reads.
```

## Reuse first

Before writing anything new:

1. Does it already exist in `presentations/widgets/shared/`, `config/helpers/`, or the
   `domain/` entities? Use it.
2. Does the Dart/Flutter stdlib cover it? Use it (`intl`, `DateTime`, `Iterable`, …).
3. Does an already-installed dependency cover it? Use it.
4. Only then write it — as the smallest thing that works.

**Never add a dependency without asking the user first.** State what it replaces and why a few
lines of code are not enough.

## No speculative code

- No abstraction with a single implementation. No interface, no factory, no base class "for later".
- No config for a value that never changes.
- No empty scaffolding files, no placeholder features.
- Build exactly what the current feature needs.

## File naming

All `snake_case`, always suffixed by its kind:

```
home_screen.dart              class HomeScreen
home_view.dart                class HomeView
movie_horizontal_listview.dart   class MovieHorizontalListview
movie_mapper.dart             class MovieMapper
movies_repository.dart        abstract MoviesRepository
movies_repository_impl.dart   class MoviesRepositoryImpl
movies_datasource.dart        abstract MoviesDatasource
moviedb_datasource.dart       class MoviedbDatasource
```

One public class per file. The file name matches the class name in `snake_case`.

## File length

- **Hard cap: 300 lines per file.** Over it, split — extract widgets, views, or helpers.
- A `build()` method over ~80 lines means a missing widget. Extract it.
- Known current deviations (to be split in phase 7): `movie_screen.dart` (~651 lines),
  `actor_screen.dart` (~338 lines). Add new code outside them rather than growing.

## Theming

All colors, text styles, spacing, radii, and motion come from `config/theme/`. **A widget that
hardcodes a color, a size, a radius, or a duration is a bug.** Branch on
`Theme.of(context).brightness`, not on a boolean flag.

Phase 1 will introduce the tokens. Until then, the existing hardcoded values are tolerated —
do not add *new* hardcoded colors, durations, or radii.

## Routes (`config/router/app_router.dart`)

`go_router` with nested routes under `/home/:page`. The `:page` param is the tab index
(0=Home, 1=Categories, 2=Favorites), switched via `IndexedStack` inside `HomeScreen`.

| Path | Screen | Params |
|---|---|---|
| `/` | redirect → `/home/0` | |
| `/home/:page` | `HomeScreen` | `page: int` (0/1/2) |
| `/home/:page/movie/:id` | `MovieScreen` | `movieId: string` |
| `/home/:page/actor/:id` | `ActorScreen` | `actorId: string` |
| `/home/:page/genre/:id/:name` | `MoviesByGenreScreen` | `genreId, genreName` |

Navigation convention: nested screens are pushed via
`context.push('/home/<currentTab>/<kind>/<id>/<name?>')`, never direct pushes.
`CustomBottomNavigation` always uses `context.go('/home/<i>')` (resets the stack).

## Data sources

- **TMDB**: `MoviedbDatasource` (and siblings) own a `Dio` client with `api_key` query param +
  `Authorization: Bearer <token>` header. Locale hardcoded `es-MX` in `BaseOptions.queryParameters`.
- **Image URLs**: built in `MovieMapper.movieDBToEntity` (`https://image.tmdb.org/t/p/w500{path}`).
  The literal `'no-poster'` is the sentinel for missing artwork; datasource filters those out
  before mapping.
- **Favorites**: Drift DB at `config/database/database.dart`, table `FavoriteMovies`. Provider:
  `favoriteMoviesProvider` (StateNotifierProvider holding `Map<int, Movie>` keyed by `movieId`).
- **Image cache**: split today — some places use `Image.network`, others `cached_network_image`.
  Phase 1 will standardize on `cached_network_image` everywhere.

## Gitflow

- `main` — only release and hotfix merges
- `develop` — only feature, release, and hotfix merges
- `feature/<kebab-case>` — local-only branches, deleted on merge
- All merges use `--no-ff`
- The user makes all commits. Never `git commit`, `git merge`, `git push`, or `git tag` unless
  explicitly asked in that message
- Commit format: `tipo(alcance): asunto en minúscula, imperativo, sin punto final`

Allowed types: `feat` `fix` `refactor` `docs` `test` `chore` `ci` `build` `perf` `style`

## Definition of done

A change is done only when:

1. It does what was asked — no more.
2. `flutter analyze` exits clean.
3. No file exceeds 300 lines (unless it's a known deviation in phase 7 cleanup).
4. Naming, layering, and comment rules above are respected.
5. No file hardcodes a color, duration, radius, or spacing (after phase 1 lands).
6. Nothing was committed (the user commits).

## Known landmines

- **`Movie.releaseDate` typing**: declared `DateTime` in `domain/entities/movie.dart` but
  `movies_slideshow.dart` and `search_movies_delegate.dart` do `(m as dynamic).releaseDate` and
  handle it as both `DateTime` and `String`. Decision needed in phase 7.
- **Riverpod import clash in `MovieScreen`**: imports `flutter_riverpod` with `hide ProviderRef`
  because `watch_providers.dart` also exports a `ProviderRef` class. Fix in phase 7 by renaming
  the model class.
- **`SearchMoviesDelegate`**: `cleanStreams()` closes `debounceMovies` but **not**
  `isLoadingStream` — minor leak each time you open search. Fixed in phase 0.
- **Provider barrel is incomplete**: `presentations/providers/providers.dart` only re-exports
  `movies/`, `search/`. New provider folders need their export added.
- **`MovieMasonry` layout hack**: `if (index == 1) ... SizedBox(height: 30)` to inset the second
  tile. Will break if column count changes. Replace with `MasonryGridView.staggered` in phase 7.
- **`'Lunes 20'` hardcoded** in `HomeScreen._HomeView.build` for the "En cines" subtitle. Not
  today-specific. Replace with `intl` `DateFormat('EEEE d')` in phase 7.
- **`.metadata` lists removed platforms** (linux, macos, windows, web) in its migration block.
  Harmless at runtime, regenerate with `flutter create . --platforms=android,ios` if it bothers
  you.
- **`test/widget_test.dart`**: stale default counter test (will fail to compile against real
  `MainApp`). Rewritten in phase 0.
- **iOS scheme**: a previous `flutter create --platforms=ios .` was needed to repair a malformed
  `Runner.xcscheme.xml`. If iOS builds start failing with LLDB Init File errors again, re-run
  that command.
- **Android `package`**: `com.example.cinemapedia` is the default. Should be `com.davidag.cinemapedia`
  or similar before the first Play upload — phase 0.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`cinemapedia` — Flutter movie browser for **iOS and Android only** (no web/desktop). TMDB API for content, Drift for local favorites, Riverpod for state, go_router for nav.

- Flutter SDK: `^3.6.0`
- Branches: `main` (PRs) / `develop` (work)
- No tests, no CI.

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

`.env` is gitignored. `main()` calls `WidgetsFlutterBinding.ensureInitialized()` then `dotenv.load(fileName: '.env')` before `runApp` — no env = crash on first network call.

## Architecture

Clean Architecture, three layers under `lib/`. Imports flow inward: `presentations` → `domain` ← `infrastructure`.

```
lib/
├── config/
│   ├── constants/environment.dart   # reads THE_MOVIE_DB_KEY + THE_MOVIE_DB_ACCESS_TOKEN
│   ├── database/database.dart       # Drift schema (FavoriteMovies table) + AppDatabase
│   ├── database/database.g.dart     # GENERATED — do not edit; regenerate via build_runner
│   ├── router/app_router.dart       # go_router, see "Routes" below
│   ├── theme/app_theme.dart
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
│   └── movies_repository.dart, actors_repository.dart, …  (7 total)
├── infrastructure/                  # concrete impls
│   ├── datasources/                 # one per domain datasource: moviedb_* + local_storage_favoritedb
│   ├── mappers/                     # DTO → entity; movie_mapper handles MovieMovieDB + MovieDetails
│   ├── models/moviedb/              # DTOs (MovieMovieDB, MovieDetails, CreditsResponse, ActorCreditsResponse)
│   └── reporsitories/               # ⚠ typo — see landmines
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

- New external system (TMDB endpoint, local table, etc.) → add abstract to `domain/datasources/`, implementation to `infrastructure/datasources/`, abstract repo to `repositories/`, repo impl to `infrastructure/reporsitories/`, wire in `presentations/providers/<feature>/`.
- DI is constructor injection. New datasource: create provider in `presentations/providers/<feature>/`, pass datasource into repo, expose repo via Provider.
- `MoviesNotifier` is the universal paginated list notifier — reused by 4 lists + 2 family providers (`similarMoviesProvider(movieId)`, `moviesByGenreProvider(genreId)`). Has built-in `isLoading` guard + 300ms post-page delay.
- DB is **not** injected — `AppDatabase()` is instantiated inline in `LocalStorageFavoriteDBDatasource`. App-wide singleton, fine for now, but means tests need overrides.
- Barrel files: `presentations/providers/providers.dart`, `widgets.dart`, `screens.dart`, `views/views.dart`. Add exports there when adding new modules.
- All UI strings are Spanish (`'En cines'`, `'Próximamente'`, `'Categorías'`, etc.). Theme color constants `0xFF0E1427`, `0xFF121A34`, `0xFF16213E` recur across screens — there's no shared gradient helper, copy/paste is the convention.

## Routes (`config/router/app_router.dart`)

`go_router` with nested routes under `/home/:page`. The `:page` param is the tab index (0=Home, 1=Categories, 2=Favorites), switched via `IndexedStack` inside `HomeScreen`.

| Path | Screen | Params |
|---|---|---|
| `/` | redirect → `/home/0` | |
| `/home/:page` | `HomeScreen` | `page: int` (0/1/2) |
| `/home/:page/movie/:id` | `MovieScreen` | `movieId: string` |
| `/home/:page/actor/:id` | `ActorScreen` | `actorId: string` |
| `/home/:page/genre/:id/:name` | `MoviesByGenreScreen` | `genreId, genreName` |

Navigation convention: nested screens are pushed via `context.push('/home/<currentTab>/<kind>/<id>/<name?>')`, never direct pushes. `CustomBottomNavigation` always uses `context.go('/home/<i>')` (resets the stack).

## Data sources

- **TMDB**: `MoviedbDatasource` (and siblings) own a `Dio` client with `api_key` query param + `Authorization: Bearer <token>` header. Locale hardcoded `es-MX` in `BaseOptions.queryParameters`.
- **Image URLs**: built in `MovieMapper.movieDBToEntity` (`https://image.tmdb.org/t/p/w500{path}`). The literal `'no-poster'` is the sentinel for missing artwork; datasource filters those out before mapping.
- **Favorites**: Drift DB at `config/database/database.dart`, table `FavoriteMovies`. Provider: `favoriteMoviesProvider` (StateNotifierProvider holding `Map<int, Movie>` keyed by `movieId`).

## Known landmines

- **Folder typo**: `lib/infrastructure/reporsitories/` (missing an `i`). Every import in the repo points to it. Rename + fix imports together if you ever do.
- **DB singleton**: `LocalStorageFavoriteDBDatasource` does `final db = AppDatabase()` in the field — no constructor injection. Easy to forget when writing tests; override the provider.
- **MoviesNotifier debounce**: built-in 300ms `Future.delayed` after every page load — do not call `loadNextPage` expecting sub-300ms re-entrancy.
- **Riverpod import clash in MovieScreen**: imports `flutter_riverpod` with `hide ProviderRef` because the `watch_providers` entity also exports a `ProviderRef` class. Don't reorder these imports casually.
- **Provider barrel is incomplete**: `presentations/providers/providers.dart` only re-exports `movies/`, `search/`. New provider folders need their export added.
- **`Assets` not registered**: `assets/icon.png` and `assets/splash/splash.png` are referenced in pubspec but `flutter:` has no `assets:` list — only `.env` is. Add the asset entries if any new image asset ships.
- **`.metadata` lists removed platforms** (linux, macos, windows, web) in its migration block. Harmless at runtime, regenerate with `flutter create . --platforms=android,ios` if it bothers you.
- **`test/widget_test.dart`**: stale default counter test (will fail to compile against real `MainApp`). Fix or delete before `flutter test`.
- **iOS scheme**: a previous `flutter create --platforms=ios .` was needed to repair a malformed `Runner.xcscheme.xml`. If iOS builds start failing with LLDB Init File errors again, re-run that command.

# Fantasy FPL Agent Context

## 1. Project Overview

- App name: `Fantasy FPL` / `fantasy`
- Main purpose: a Flutter app for tracking a Premier League Fantasy manager entry, including onboarding, home dashboard, league standings, picks, history, live gameweek data, and market comparisons.
- Flutter/Dart: `sdk: ^3.7.0`; app is built with Flutter Material 3.
- State management: `flutter_bloc` with `Cubit`-based state handling (`ManagerCubit`, `LeagueCubit`, `HistoryCubit`, `PicksCubit`, `BootstrapCubit`, `LiveCubit`).
- Architecture pattern: feature-first, layered Clean Architecture style, not strict MVVM. Each feature is split into:
  - `data/models`
  - `data/repositories`
  - `domain/repositories`
  - `presentation/cubit`
  - `presentation/pages`
  - `presentation/widgets`
- Navigation: `go_router` is used for screen routing via `core/router/app_router.dart`.
- Dependency injection: `get_it` is used through `core/di/injection.dart`.
- API access: the project uses `dio` to call the Premier League Fantasy API (`https://fantasy.premierleague.com/api`).

## 2. Folder Architecture

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── di/
│   │   └── injection.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── exports.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   └── custom_bloc_observer.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/
│   ├── bootstrap/
│   │   ├── data/models/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/cubit/
│   ├── history/
│   │   ├── data/models/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/
│   ├── home/
│   │   └── presentation/
│   ├── league/
│   │   ├── data/models/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/
│   ├── live/
│   │   ├── data/models/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/
│   ├── manager/
│   │   ├── data/models/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/
│   ├── market/
│   │   └── presentation/
│   ├── onboarding/
│   │   └── presentation/
│   ├── picks/
│   │   ├── data/models/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/
│   ├── splash/
│   │   └── presentation/
│   └── ...
├── shared/
│   └── widgets/
├── assets/
│   └── images/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

### How the app is organized in practice

- `core/` contains cross-cutting infrastructure: route config, DI, theme, constants, network client, exception/error types.
- `features/*/data/` holds API response models and repository implementations.
- `features/*/domain/` defines repository contracts / use-case boundaries. API repository contracts return `Future<Either<Failure, Model>>` using `dartz`.
- `features/*/presentation/` contains Cubits and UI widgets/pages, with a UI-first composition pattern.
- `shared/` contains reusable widgets like cards, nav UI, stat blocks.
- `shared/widgets/app_snack_bar.dart` provides the reusable, theme-aligned `AppSnackBar.show` helper. Specify `AppSnackBarType.info`, `.success`, `.warning`, or `.error` for the message context.
- `main.dart` boots app initialization, installs `CustomBlocObserver`, initializes dependencies, then runs `MyApp` with MaterialApp.router.

## 3. Design System & Figma Integration

### Theme and design tokens

The app uses a centralized dark design system defined in:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`

Key visual rules:

- Default theme is dark mode.
- Material 3 is enabled via `useMaterial3: true`.
- Typography uses `GoogleFonts.outfit` with a custom `TextTheme` defined in `AppTheme`.
- Card, button, divider, input, and app bar styles are configured centrally through `ThemeData`.
- Colors are grouped into semantic tokens such as:
  - `primary`: `#7C4DFF`
  - `electricBlue`: `#58C7FF`
  - `warmOrange`: `#FFA45B`
  - `background`: `#0B0E14`
  - `surface`: `#111722`
  - `textPrimary`: `#F0F0FF`
  - `textSecondary`: `#8A8FA8`

### Figma / plugin integration status

- There is no active Figma plugin or generated design-system asset in this repo.
- The project appears to follow a handcrafted token system rather than a live Figma sync.
- For future edits, the canonical design sources are the files above (`AppColors` + `AppTheme`), not a generated plugin artifact.
- If a design system is later synced from Figma, it should be represented as a centralized token source and then consumed through the same theme layer, rather than scattered across widgets.

## 4. Key Conventions & Rules

When writing or editing code in this project, follow these rules:

- Prefer `const` constructors and other immutable values wherever possible.
- Keep UI and business logic separate; put state transitions in Cubits and repository logic in `data`/`domain` layers.
- Use strict null safety and explicit types.
- Use `final` for local values that are not reassigned.
- Prefer `Equatable` for Cubit state objects.
- Centralize all API endpoints in `core/constants/app_constants.dart`.
- Centralize theme values in `core/theme/app_colors.dart` and `core/theme/app_theme.dart`; do not hardcode colors in individual widgets unless absolutely required.
- Use `go_router` and `AppRouter` instead of ad hoc navigation logic.
- Register repositories and Cubits in `core/di/injection.dart` using `GetIt`.
- Store user-specific state like manager ID in `SharedPreferences` using the `AppConstants` keys.
- Follow the feature-first structure; new work should live under a matching feature folder.
- Keep model parsing and JSON mapping as clear, typed conversions (`fromJson` methods).
- Avoid leaking network or data-layer concerns into Widgets; keep them behind repository/Cubit boundaries.
- For API-backed features, keep the result flow consistent with bootstrap and picks: the repository interface returns `Either<Failure, Model>`, the data implementation catches `ServerException` and other exceptions and returns `Left(Failure(...))`, and the Cubit maps the result to loaded/error states with `fold`.
- Keep pagination-specific state in the owning Cubit. For league standings, initial-load failures produce `LeagueError`, while next-page failures preserve loaded standings and set `paginationError`.

## 5. Core Dependencies

From `pubspec.yaml`:

- `flutter_bloc` — Cubit-based state management
- `equatable` — value comparison for state objects
- `get_it` — dependency injection
- `dio` — HTTP client for the Fantasy Premier League API
- `shared_preferences` — persistent local settings such as manager ID
- `go_router` — app routing
- `cached_network_image` — image caching/loading
- `google_fonts` — custom typography
- `fl_chart` — charting for stats/history UI
- `shimmer` — loading placeholders
- `skeletonizer` — skeleton loading states
- `cupertino_icons` — default icon set

### Dev dependencies

- `flutter_test`
- `flutter_lints`

## 6. API & Data Flow

The API-backed features (`bootstrap`, `picks`, `manager`, `history`, `league`, and `live`) follow this repository pattern:

1. `Presentation` layer reads state from `Cubit`.
2. `Cubit` calls a repository interface.
3. Repository interface returns `Future<Either<Failure, Model>>`.
4. Repository implementation calls `DioClient`, maps response JSON into typed models, and returns `Right(model)` on success.
5. The implementation converts `ServerException` and other thrown errors into `Left(Failure(errMessage: ...))`.
6. The Cubit emits loading before the request, then uses `fold` to emit the loaded or error state.
7. UI rebuilds from Cubit state (`Initial`, `Loading`, `Loaded`, `Error`).

League pagination follows the same `Either` result handling while keeping already-loaded standings visible when a next-page request fails.

Common endpoint patterns include:

- `bootstrap-static/`
- `entry/{id}/`
- `entry/{id}/history/`
- `entry/{id}/event/{gw}/picks/`
- `leagues-classic/{leagueId}/standings/`
- `event/{gw}/live/`

`home`, `market`, `onboarding`, and `splash` currently do not define their own repository/Cubit API flows; avoid adding repository boilerplate to these features unless they gain data-fetching responsibilities.

## 7. Working Notes for Future AI Agents

- This project is not a generic starter app; it is a domain-specific FPL dashboard.
- The core data source is the Premier League Fantasy API, not a custom backend.
- The app has a strong dark-theme, sports-dashboard visual identity.
- Add new features by extending existing feature folders and keeping repository + Cubit + UI responsibilities layered.
- Prefer reusing `AppColors`, `AppTheme`, and `AppConstants` instead of introducing new one-off config objects.
- Because there is no Figma sync tool in the repository, manual theme changes should happen in `core/theme/*` and be validated visually in app screens.

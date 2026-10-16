# FantaXI

FantaXI is a Flutter dashboard for following a Fantasy Premier League team. It brings manager details, squad picks, league standings, season history, live gameweek scores, and player comparisons into one app.

The app uses the public Fantasy Premier League API and a dark, sports-inspired interface.

## Features

- **Home dashboard** — manager overview, gameweek status, league summaries, and quick actions.
- **Squad picks** — view a manager's team and formation for a selected gameweek.
- **Leagues** — browse classic league standings with search and pagination.
- **History** — review season performance and gameweek results.
- **Live gameweek** — follow player points and live statistics.
- **Player market** — search and compare players.
- **Onboarding** — save a manager entry ID for personalized data.

## Built with

- Flutter and Dart
- `flutter_bloc` and Cubit for state management
- `go_router` for navigation
- `dio` for HTTP requests
- `get_it` for dependency injection
- `dartz` for typed repository results
- Premier League Fantasy API: `https://fantasy.premierleague.com/api`

## Getting started

### Requirements

- Flutter SDK compatible with Dart `^3.7.0`
- Xcode for iOS builds on macOS
- Android Studio or an Android SDK for Android builds

### Run locally

```bash
git clone <repository-url>
cd fantasy
flutter pub get
flutter run
```

To build a release, use the Flutter build command for your target platform. For example:

```bash
flutter build apk --release
```

## Architecture

The code is organized by feature under `lib/features/`, with shared infrastructure in `lib/core/` and reusable UI in `lib/shared/`.

API-backed features use a repository flow:

1. A presentation Cubit requests data from a domain repository interface.
2. The data repository implementation calls `DioClient` and maps the response into a typed model.
3. Repository methods return `Either<Failure, Model>` so request or parsing errors are represented as failures.
4. The Cubit emits loading, loaded, or error states for the UI.

Repositories and Cubits are registered in `lib/core/di/injection.dart`. API paths and local storage keys are defined in `lib/core/constants/app_constants.dart`.

```text
lib/
├── core/          # API client, dependency injection, routing, errors, theme
├── features/      # bootstrap, history, home, league, live, manager,
│                  # market, onboarding, picks, splash
└── shared/        # reusable widgets
```

## Data and privacy

FantaXI reads football data from the public Fantasy Premier League API. The manager entry ID and onboarding status are stored locally using the app's configured storage keys. No API credentials are required for the configured endpoints.

## Development

```bash
flutter analyze
flutter test
```

Format Dart files with:

```bash
dart format lib
```

## License

No license is currently specified. Contact the repository owner before redistributing this project or its assets.

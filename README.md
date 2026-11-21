# FantaXI

<p align="center">
  <img src="assets/images/fantaxi.png" alt="FantaXI Logo" width="150" />
</p>

<h3 align="center">Your Fantasy Premier League Companion</h3>

<p align="center">
  Follow your squad, track live gameweeks, explore leagues, and stay updated with everything happening throughout the season.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/State%20Management-Flutter%20Bloc-blue" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-success" />
</p>

---

## Overview

FantaXI is a Flutter application designed to provide a comprehensive Fantasy Premier League experience.

It connects to the public Fantasy Premier League API and brings together manager statistics, squad picks, league standings, season history, live gameweek scores, player comparisons, and match information in one football-focused dashboard.

Whether you want to follow your team's performance, analyze your progress throughout the season, or explore upcoming fixtures, FantaXI provides the tools to keep everything in one place.

## Screenshots

### Home & Fantasy

<p align="center">
  <img src="https://github.com/user-attachments/assets/6322e8dd-2dbf-4e13-ac17-7c7b9351c646" width="180" alt="Home Dashboard" />
  <img src="https://github.com/user-attachments/assets/31f7e340-5732-46b3-af0d-db996708e1f8" width="180" alt="Squad Picks" />
  <img src="https://github.com/user-attachments/assets/f9ba695b-e361-4c20-b611-5c55a3845aef" width="180" alt="Leagues" />
</p>

<p align="center">
  <sub>Home Dashboard • Squad • Leagues</sub>
</p>

### League & Performance

<p align="center">
  <img src="https://github.com/user-attachments/assets/189cfbb1-d133-457b-9ee8-a4fc090dc35a" width="180" alt="League Standings" />
  <img src="https://github.com/user-attachments/assets/114b5487-a89d-4f5b-bbc1-5edbeb09a527" width="180" alt="Gameweek Points" />
  <img src="https://github.com/user-attachments/assets/36e3f822-6812-4feb-b059-007454e41498" width="180" alt="Season History" />
</p>

<p align="center">
  <sub>League Standings • Gameweek Points • History</sub>
</p>

### Players & Matches

<p align="center">
  <img src="https://github.com/user-attachments/assets/c8720a6c-9705-455b-afa4-99b9a5caf4f6" width="180" alt="Player Market" />
  <img src="https://github.com/user-attachments/assets/dccba47d-5177-42ec-be5f-ffdbde5588ac" width="180" alt="Matches" />
  <img src="https://github.com/user-attachments/assets/b9ff429d-4469-4fd0-b6a8-fad8bc243408" width="180" alt="Match Timeline" />
</p>

<p align="center">
  <sub>Market • Matches • Match Timeline</sub>
</p>

### Match Details

<p align="center">
  <img src="https://github.com/user-attachments/assets/41c83426-d1e4-4c3d-af09-956b7920c050" width="180" alt="Match Lineups" />
  <img src="https://github.com/user-attachments/assets/e7680d55-9136-4bfb-806f-2c9b1cd1e8a4" width="180" alt="Match Statistics" />
  <img src="https://github.com/user-attachments/assets/12116b45-7aec-4cf0-83ca-c253a1a842ce" width="180" alt="Appearance Settings" />
</p>

<p align="center">
  <sub>Lineups • Match Statistics • Appearance</sub>
</p>

### App Experience

<p align="center">
  <img src="https://github.com/user-attachments/assets/927b6d23-267d-4bd5-a8f2-cd2bd4a156ec" width="180" alt="Splash Screen" />
  <img src="https://github.com/user-attachments/assets/e507c86f-c19f-41f7-ba87-bb1f21e374eb" width="180" alt="Onboarding Screen" />
</p>

<p align="center">
  <sub>Splash Screen • Onboarding</sub>
</p>

---

## Features

### Fantasy Dashboard
- Manager overview and season statistics.
- Overall rank and squad value.
- Gameweek progress and performance.
- Gameweek MVP highlights.

### Squad Management
- View manager picks for any available gameweek.
- Squad formation and starting lineup.
- Captain and vice-captain identification.
- Substitutes bench and player positions.

### Leagues & Standings
- Browse classic leagues and mini-leagues.
- Filter leagues by type.
- Search leagues and cups.
- View overall and gameweek standings.
- Track your position and points gap to first place.
- Search managers.
- Explore Top 10, Near Me, and Rivals filters.

### Season History
- Overall rank trajectory chart.
- Best overall rank and best gameweek.
- Transfer history.
- Squad value and bench points.
- Gameweek-by-gameweek results.
- Historical chip usage.

### Player Market
- Browse and search players.
- Filter by position and price.
- Explore player form and total points.
- Filter players by team.

### Matches & Fixtures
- Browse matchweek fixtures grouped by day.
- Follow live match scores.
- Explore detailed match information.
- View match timelines and events.
- Check starting lineups and formations.
- Analyze match statistics, commentary, and league table impact.

### Live Gameweek
- Follow live player points.
- Track live gameweek statistics.
- Monitor player performance during matches.

### Personalization & Onboarding
- Light, dark, and system themes.
- Change the connected manager entry ID.
- Onboarding flow to connect a Fantasy Premier League manager.

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| flutter_bloc | State management |
| Cubit | Feature-level state handling |
| go_router | Declarative navigation |
| Dio | HTTP networking |
| get_it | Dependency injection |
| dartz | Functional programming and typed results |
| Fantasy Premier League API | Football and fantasy data source |

**API:** [Fantasy Premier League API](https://fantasy.premierleague.com/api)

---

## Architecture

FantaXI follows a **Feature-First Clean Architecture** approach to keep the codebase modular, maintainable, and easier to extend.

Each API-driven feature separates its presentation, domain, and data responsibilities.

### Application Layers

**1. Presentation Layer**
- Contains screens, reusable feature widgets, Cubits, and states.
- Handles UI rendering and user interactions.
- Reacts to loading, success, and failure states.

**2. Domain Layer**
- Defines repository contracts.
- Keeps business logic independent of networking and UI implementation.
- Uses typed results to represent successful operations and failures.

**3. Data Layer**
- Implements repository contracts.
- Handles API requests through Dio.
- Parses API responses into typed models.

### API Data Flow

```text
UI / Screen
    |
    v
Cubit
    |
    v
Repository Contract
    |
    v
Repository Implementation
    |
    v
Dio Client
    |
    v
Fantasy Premier League API
    |
    v
Response Model
    |
    v
Either<Failure, Model>
    |
    v
Cubit State
    |
    v
UI Update
```

### Error Handling

Repositories return `Either<Failure, Model>` using Dartz.

This provides explicit success and failure handling instead of relying on unstructured API responses.

Cubits manage the application state and emit the appropriate loading, loaded, or error state for the UI.

### Project Structure

```text
lib/
├── core/
│   ├── constants/      # API endpoints and app constants
│   ├── di/             # Dependency injection
│   ├── errors/         # Failures and error handling
│   ├── network/        # Dio client and networking
│   ├── router/         # Application navigation
│   └── theme/          # App themes and appearance
│
├── features/
│   ├── bootstrap/
│   ├── history/
│   ├── home/
│   ├── league/
│   ├── live/
│   ├── manager/
│   ├── market/
│   ├── matches/
│   ├── onboarding/
│   ├── picks/
│   └── splash/
│
└── shared/             # Reusable application widgets

assets/
└── images/
    └── screenshots/
```

Repositories and Cubits are registered through:

```text
lib/core/di/injection.dart
```

API endpoints and local storage keys are defined in:

```text
lib/core/constants/app_constants.dart
```

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK with Dart `^3.7.0`.
- Android Studio.
- Android SDK and a configured Android emulator or physical device.
- Xcode on macOS for iOS development.

### Installation

Clone the repository:

```bash
git clone https://github.com/ElsaidAtif14/FantaXI.git
```

Navigate to the project directory:

```bash
cd FantaXI
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To check available devices:

```bash
flutter devices
```

### Build Android APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK can be found at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Data & Local Storage

FantaXI retrieves football and Fantasy Premier League data from the public Fantasy Premier League API.

- No API credentials are required for the configured endpoints.
- The manager entry ID is stored locally on the device.
- Onboarding status is persisted locally.
- API responses are mapped into typed models before reaching the presentation layer.

Build outputs, local tool state, and generated platform files are excluded through `.gitignore`.

Generated build directories should not be committed to the repository.

---

## Development

Useful commands for maintaining the project:

### Static Analysis

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Format Dart Files

```bash
dart format lib
```

---

## Future Improvements

Potential areas for further development include:

- Expanded player comparison and performance analytics.
- More detailed live match insights.
- Additional statistics and visualizations.
- Further automated testing and CI/CD improvements.

---

## License

No license is currently specified for this repository.

Please contact the repository owner before redistributing the project or its assets.

---

<p align="center">
  Built with Flutter and a passion for football.
</p>

<p align="center">
  <a href="https://github.com/ElsaidAtif14">GitHub Profile</a>
  •
  <a href="https://github.com/ElsaidAtif14/FantaXI">FantaXI Repository</a>
</p>

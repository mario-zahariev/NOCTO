# Architecture Overview

NOCTO is a local-first Swift/iOS app. The code remains the source of truth; this document records the current technical posture, data boundaries, and operational constraints.

## Current Runtime Shape

- App UI and app-facing logic live in `NOCTO/`.
- Shared venue decoding and validation live in `Sources/NOCTOCore/`.
- `venues.json` is the active local venue data source.
- `Firebase` is detached from runtime, target linkage, and tracked production resources.
- `OperationalSnapshot` computes local signals for `Пулс` and `Админ`.

## Layers

1. Presentation (`ContentView`, `HomeView`, `FavoritesView`, `NightPulseView`, `ProfileView`, debug-only `AdminDashboardView`)
2. Domain model (`Venue`)
3. Data access boundary (`VenueRepository`, `VenueDataSource`)
4. Local data adapter (`LocalVenueDataSource`)
5. Shared decode and validation (`NOCTOCore`)
6. State and persistence (`FavoritesManager` with `UserDefaults` for favorite UUID storage)
7. Local operational signals (`OperationalSnapshot`)
8. Cross-cutting utilities (`Haptics`, `LocationManager`, theme/extensions)

## Data Flow

1. `ContentView` requests venues via `VenueRepository`.
2. `VenueRepository` delegates loading through `VenueDataSource`.
3. The current adapter, `LocalVenueDataSource`, loads `venues.json`.
4. `LocalVenueDataSource` validates and decodes venue payloads through `NOCTOCore`.
5. Views receive clean `Venue` models, not raw JSON.
6. `ContentView`, `HomeView`, and `FavoritesView` call `FavoritesManager` for favorite state reads and mutations.
7. `FavoritesManager` persists favorite venue UUIDs locally in `UserDefaults`.
8. `OperationalSnapshot` derives local operational signals from validated venue and app state.

## Local-First Boundaries

- UI can be expressive, but the data boundary must stay clear and stable.
- External JSON input must be validated before rendering.
- Repository failures should surface as explicit, typed errors.
- `VenueRepository` and `FavoritesManager` stay decoupled and are composed by `ContentView`.
- `Админ` remains an operational/debug surface and should not become consumer navigation.
- Remote data work starts at the `VenueDataSource` boundary, not inside views.

## Firebase Posture

Firebase remains detached until a remote data path has product value and an implemented adapter contract.

Current decision:

- **Runtime posture:** no `FirebaseApp.configure()` path in the app flow.
- **Build posture:** no `firebase-ios-sdk`, `FirebaseAnalytics`, or `FirebaseFirestore` target linkage.
- **Resource posture:** no tracked production `GoogleService-Info.plist`; only `NOCTO/GoogleService-Info.plist.example` stays in git as the placeholder fixture.
- **Rationale:** local-first architecture is still the source of truth; enabling Firebase before remote adapter contracts would add operational complexity without product value.

Firebase can re-enter only when these conditions exist:

- remote `VenueDataSource` adapter
- defined backend data contract
- telemetry or health model
- fallback strategy
- security rules and secrets hygiene
- clear product value in the PR

Historical chat or brief material that describes a Firebase Firestore repository as current architecture is deprecated context, not implementation direction.

## CI Guardrail

CI runs `scripts/ci/check_firebase_detached.sh` before tests.

The guard fails if:

- `NOCTO.xcodeproj/project.pbxproj` contains Firebase linkage markers (`firebase-ios-sdk`, `FirebaseAnalytics`, `FirebaseFirestore`)
- `GoogleService-Info.plist` is re-added to target Build Resources
- the real `NOCTO/GoogleService-Info.plist` becomes tracked by git
- `NOCTO/GoogleService-Info.plist.example` is missing or no longer contains the expected placeholder values

Purpose: keep Firebase detachment explicit and prevent accidental re-attach in routine project edits.

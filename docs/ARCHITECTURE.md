# Architecture Overview

## Layers

1. Presentation (`NOCTO/*.swift` view files)
2. Domain model (`Venue`)
3. Data access (`VenueRepository`)
4. State and persistence (`FavoritesManager` with `UserDefaults` for favorite UUID storage)
5. Cross-cutting utilities (`Haptics`, `LocationManager`, theme/extensions)

## Data Flow

1. `ContentView` requests venues via `VenueRepository`.
2. `VenueRepository` delegates loading through `VenueDataSource` (current implementation: `LocalVenueDataSource`).
3. `LocalVenueDataSource` loads `venues.json`, validates entries via `NOCTOCore`, and returns clean venue payloads.
4. `ContentView`, `HomeView`, and `FavoritesView` call `FavoritesManager` for favorite state mutations/reads.
5. `FavoritesManager` persists favorite venue UUIDs in `UserDefaults`.
6. `VenueRepository` and `FavoritesManager` stay decoupled and are composed by `ContentView`.

## Guardrails

- Fail fast with explicit, typed repository errors.
- Validate all external JSON input before rendering.
- Keep UI and data loading concerns separated.

## Firebase Posture Decision Gate (2026-04-29)

- Option A: **Enable Firebase runtime now** (`FirebaseApp.configure`, analytics/firestore wiring, operational telemetry).
- Option B: **Detach Firebase dependencies temporarily** until remote data path is implemented.

### Current decision

- **Runtime posture:** Firebase remains detached at runtime (no Firebase initialization path in app flow).
- **Build posture:** Firebase is detached from NOCTO target linkage (`FirebaseAnalytics`/`FirebaseFirestore` removed from frameworks and package dependencies).
- **Resource posture:** `GoogleService-Info.plist` is removed from target build resources and from tracked source; only `GoogleService-Info.plist.example` stays in git.
- **Rationale:** local-first architecture is still the source of truth; enabling Firebase before remote adapter contracts would add operational complexity without product value.
- **Exit criteria to move to Option A:** `VenueDataSource` remote adapter implemented, telemetry contract defined, and health metrics wired in Admin/Pulse surfaces.

### CI Guardrail (Post-Detachment)

- CI runs `scripts/ci/check_firebase_detached.sh` before tests.
- The guard fails if `NOCTO.xcodeproj/project.pbxproj` contains Firebase linkage markers (`firebase-ios-sdk`, `FirebaseAnalytics`, `FirebaseFirestore`).
- The guard fails if `GoogleService-Info.plist` is re-added to target Build Resources or tracked source.
- Purpose: keep Firebase detachment explicit and prevent accidental re-attach in routine project edits.

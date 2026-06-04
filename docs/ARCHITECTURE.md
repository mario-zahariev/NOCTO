# Architecture Overview

## Layers

1. Presentation (`NOCTO/*.swift` view files)
2. App state boundaries (`VenueCatalogViewModel`)
3. Domain model (`Venue`)
4. Data access (`VenueRepository`)
5. State and persistence (`FavoritesManager` with `UserDefaults` for favorite UUID storage)
6. Cross-cutting utilities (`Haptics`, `LocationManager`, theme/extensions)

## Data Flow

1. `VenueCatalogView` renders catalog state passively and delegates load/refresh commands back to `ContentView`.
2. `VenueCatalogViewModel` owns app-facing catalog loading state and talks only to `VenueRepositoryProviding`.
3. `ContentView` composes the catalog state boundary without constructing local data sources directly.
4. `VenueRepository` delegates loading through `VenueDataSource` (current implementation: `LocalVenueDataSource`).
5. `LocalVenueDataSource` loads `venues.json`, validates entries via `NOCTOCore`, and returns clean venue payloads.
6. `ContentView`, `VenueCatalogView`, `HomeView`, and `FavoritesView` call `FavoritesManager` for favorite state mutations/reads.
7. `FavoritesManager` persists favorite venue UUIDs in `UserDefaults`.
8. `VenueRepository`, `VenueCatalogViewModel`, and `FavoritesManager` stay decoupled and are composed by presentation views.

## Guardrails

- Fail fast with explicit, typed repository errors.
- Validate all external JSON input before rendering.
- Keep UI and data loading concerns separated.
- `ArchitectureGuardTests` parse project Swift files with `SwiftSyntax` and fail `swift test` if presentation code imports infrastructure frameworks, bypasses repository boundaries, or reintroduces Firebase runtime code.
- Presentation views may depend on app-facing boundaries such as `VenueRepository`, but must not import or construct local storage, network, Firebase, Keychain, or low-level security APIs directly.
- `Semgrep CE` enforces source-level security rules that complement the SwiftSyntax architecture tests: no insecure HTTP literals, no direct `URLSession.shared`, no TLS trust bypass, no weak crypto, no direct Keychain usage outside a dedicated security module, and no weakened ATS plist settings.

## Firebase Posture Decision Gate (2026-04-29)

- Option A: **Enable Firebase runtime now** (`FirebaseApp.configure`, analytics/firestore wiring, operational telemetry).
- Option B: **Detach Firebase dependencies temporarily** until remote data path is implemented.

### Current decision

- **Runtime posture:** Firebase remains detached at runtime (no Firebase initialization path in app flow).
- **Build posture:** Firebase is detached from NOCTO target linkage (`FirebaseAnalytics`/`FirebaseFirestore` removed from frameworks and package dependencies).
- **Resource posture:** `GoogleService-Info.plist` is removed from target build resources and must remain untracked/ignored; only `GoogleService-Info.plist.example` stays in git as the placeholder fixture.
- **Rationale:** local-first architecture is still the source of truth; enabling Firebase before remote adapter contracts would add operational complexity without product value.
- **Exit criteria to move to Option A:** `VenueDataSource` remote adapter implemented, telemetry contract defined, and health metrics wired in Admin/Pulse surfaces.

### CI Guardrail (Post-Detachment)

- CI runs `scripts/ci/check_firebase_detached.sh` before tests.
- The guard fails if `NOCTO.xcodeproj/project.pbxproj` contains Firebase linkage markers (`firebase-ios-sdk`, `FirebaseAnalytics`, `FirebaseFirestore`).
- The guard fails if `GoogleService-Info.plist` is re-added to target Build Resources.
- The guard fails if the real `NOCTO/GoogleService-Info.plist` is tracked by git; that file must stay ignored and local-only.
- The guard fails if `NOCTO/GoogleService-Info.plist.example` is missing or no longer contains the expected placeholder values.
- Purpose: keep Firebase detachment explicit and prevent accidental re-attach in routine project edits.

<div align="center">

<img src="docs/svg/hero-nocto-dark.svg" alt="NOCTO — Night Intelligence for Sofia" />

</div>

<br>

<div align="center">

**Premium nightlife intelligence for Sofia.**  
Local-first. Signal-driven. Built in SwiftUI.

<br>

[![CI](https://github.com/mario-zahariev/NOCTO/actions/workflows/ci.yml/badge.svg)](https://github.com/mario-zahariev/NOCTO/actions) [![Swift](https://img.shields.io/badge/Swift-5.10-F05138?logo=swift&logoColor=white)](https://swift.org) [![iOS](https://img.shields.io/badge/iOS-17%2B-black?logo=apple&logoColor=white)](https://developer.apple.com/ios/) [![License](https://img.shields.io/github/license/mario-zahariev/NOCTO)](LICENSE)

</div>

---

## Why NOCTO exists

Most nightlife apps are noise — stale listings, generic ratings, and tracking you didn't agree to.

NOCTO is the opposite: a local-first, zero-tracker guide to Sofia's nightlife with a computed operational signal called **Night Pulse** — a real-time composite read of venue activity, freshness, and completeness. No backend required to get started. No silent degradation when data is missing.

---

## What you get

| Surface | What it does |
|---|---|
| **Home** | Hero parallax card + curated venue list with proximity-aware ranking |
| **Map** | Full-city MapKit view — all venues as annotated pins |
| **Favorites** | On-device saved venues, persisted locally via `UserDefaults` |
| **Night Pulse** | Computed signal: pulse index · type mix · latency band · completeness |
| **Profile** | Night Pass identity surface; Admin behind `#if DEBUG` only |

### Night Pulse — what the signal means

- **Pulse index** — composite activity score for the active venue dataset
- **Type mix** — distribution across `club · bar · lounge · event · other`
- **Latency band** — data freshness window for the current signal
- **Completeness** — share of venue records that passed validation and are renderable

---

## Get started

NOCTO is currently source-first. TestFlight and App Store distribution are not declared yet.

```zsh
git clone https://github.com/mario-zahariev/NOCTO.git
open NOCTO.xcodeproj
# Select NOCTO scheme → run on iOS 17+ simulator or device
```

**Requirements:** iOS 17.0 · Xcode 26.1+ · Swift 5.10

---

## Architecture

NOCTO is built around a strict data boundary: no invalid venue record ever reaches a view.

```text
ContentView
  └── VenueRepository
        └── VenueDataSource              ← protocol boundary
              └── LocalVenueDataSource
                    └── LocalVenueRepository  (NOCTOCore)
                          └── VenueRepositoryCore → [Venue]  ← filter(\.isValid)
                                        ↑
                                  venues.json  (bundle resource)

FavoritesManager      @MainActor · @Published UUID set · UserDefaults
OperationalSnapshot   pulse index · type mix · latency band · signal confidence
LocationManager       CLLocationManager · authorizedWhenInUse · 100m accuracy
```

Every layer fails loudly with typed errors. No degraded state reaches a view.

<details>
<summary><strong>Full project structure</strong></summary>

```text
NOCTO/
├── NOCTOApp.swift              @main · WindowGroup entry point
├── ContentView.swift           Root composition — async venue load, owns FavoritesManager
├── HomeView.swift              HeroParallaxCard + venue list, NavigationStack
├── VenueDetailView.swift       MapKit single-venue map, address, working hours
├── AllVenuesMapView.swift      Full-map MKCoordinateRegion, all venue annotations
├── FavoritesView.swift         Filtered venue list, ContentUnavailableView on empty
├── NightPulseView.swift        OperationalSnapshot cards — hero, signals, type mix, quality
├── ProfileView.swift           Night Pass identity + metrics; Admin link (#if DEBUG)
├── AdminDashboardView.swift    Dev-only operational stat list — counts, health, latency
│
├── VenueCard.swift             Type label · name · address · hours · favorite toggle
├── HeroParallaxCard.swift      ParallaxCard + accent gradient overlay, 180pt height
├── ParallaxCard.swift          3D rotation via PreferenceKey scroll position tracking
├── BlurView.swift              UIVisualEffectView bridge — .systemUltraThinMaterialDark
├── MicroFeedback.swift         ViewModifier — scaleEffect(0.98), .easeOut(0.12s) on press
│
├── FavoritesManager.swift      @MainActor ObservableObject — UUID set + UserDefaults
├── LocationManager.swift       CLLocationManagerDelegate — authorizedWhenInUse
├── OperationalSnapshot.swift   Computed: trafficIndex · typeSignals · latencyBandLabel
├── VenueRepository.swift       Composes any VenueDataSource
├── VenueDataSource.swift       Protocol + LocalVenueDataSource concrete adapter
├── Venue.swift                 typealias Venue = NOCTOCore.Venue
│
├── NoctoTheme.swift            Design tokens: background #050609 · accent #FD5B8A
├── Color+Hex.swift             Color(hex:) — Scanner, sRGB, 6-digit only
└── Haptics.swift               UIImpactFeedbackGenerator(.light) · .notificationOccurred(.success)

Sources/NOCTOCore/
├── VenueCore.swift             Venue model — Codable · Identifiable · CLLocationCoordinate2D
│                               isValid: non-empty name + coordinate bounds
├── VenueRepositoryCore.swift   JSONDecoder → filter(\.isValid) — throws .invalidJSON / .noValidVenues
└── LocalVenueRepository.swift  Bundle resource lookup → Data → VenueRepositoryCore

Tests/NOCTOCoreTests/
└── VenueRepositoryCoreTests    valid payload · invalid JSON · all-invalid venue entries

scripts/
├── validate_venues_json.py     9 required fields · UUID · coordinate range · ≥10 entries
└── ci/check_firebase_detached.sh  Guards Firebase detachment and example plist placeholder values
```

</details>

---

## NOCTOCore

`NOCTOCore` is a local Swift package enforcing the venue decode-and-validate contract.

```swift
// Load from app bundle
import NOCTOCore
let venues = try LocalVenueRepository().loadVenues()
// [Venue] — decoded, validated, invalid entries removed at source

// Decode from raw Data
let venues = try VenueRepositoryCore().decode(from: data)
// throws .invalidJSON or .noValidVenues — never silently degrades
```

Once semantic version tags are published:

```swift
.package(url: "https://github.com/mario-zahariev/NOCTO.git", from: "1.0.0")
```

---

## Data contract

Every record in `venues.json` must pass `scripts/validate_venues_json.py` and `VenueCore.isValid` at decode time.

```json
{
  "id":           "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABC",
  "name":         "Bedroom Premium",
  "imageName":    "bedroom",
  "type":         "club",
  "description":  "Премиум клубно преживяване с фокус върху house и melodic nights.",
  "latitude":     42.6977,
  "longitude":    23.3219,
  "address":      "бул. Витоша 12, София",
  "workingHours": "22:00-06:00"
}
```

All nine fields are required. `VenueCore.isValid` enforces non-empty `name` and coordinate bounds at runtime. The Python validator additionally requires a minimum of 10 entries.

**Venue types:** `club · bar · lounge · event · other`

---

## CI

Four gates run on every push to `main` and every pull request. All four must pass.

```zsh
# 1. Firebase detachment guard
bash scripts/ci/check_firebase_detached.sh

# 2. Venue schema validation
python3 scripts/validate_venues_json.py

# 3. NOCTOCore unit tests
swift test

# 4. App smoke build
xcodebuild -project NOCTO.xcodeproj \
           -scheme NOCTO \
           -sdk iphonesimulator \
           -destination 'generic/platform=iOS Simulator' \
           build
```

The `Docs and Coverage` workflow generates a Swift package coverage JSON and a `NOCTOCore` DocC archive on changes to package sources, tests, `Package.swift`, or the workflow itself.

---

## Linting

SwiftLint runs against `NOCTO/` and `Sources/`.

| Rule | Level |
|---|---|
| `force_cast` | error |
| `force_try` | error |
| `force_unwrapping` | opt-in, flagged |
| Line length | warning @ 140 · error @ 180 |

`todo` is disabled — tracked in the roadmap instead.

---

## Firebase

Fully detached at every level. Firebase re-enters only when a remote `VenueDataSource` adapter exists — with a defined contract, security rules, health metrics, and a fallback strategy. Not before.

<details>
<summary>Detachment checklist</summary>

```
no FirebaseApp.configure()
no firebase-ios-sdk package reference in project.pbxproj
no FirebaseAnalytics or FirebaseFirestore target linkage
no GoogleService-Info.plist in target Build Resources
NOCTO/GoogleService-Info.plist remains ignored and local-only
NOCTO/GoogleService-Info.plist.example remains the tracked placeholder fixture
```

</details>

```zsh
# Create a local Firebase config only when intentionally testing Firebase locally
cp NOCTO/GoogleService-Info.plist.example NOCTO/GoogleService-Info.plist
```

---

## Roadmap

| Area | Status | Next |
|---|---|---|
| Local venue intelligence | ✦ Active | Expand `OperationalSnapshot` Night Pulse signals |
| Profile · Night Pass | ✦ Active | Real user state and preference persistence |
| Admin | ✦ Done (Dev-only) | Keep `#if DEBUG` gate; keep it out of consumer navigation |
| Remote backend | ◯ Planned | Define `VenueDataSource` remote adapter contract first |
| UI coverage | ◯ Planned | Snapshot and smoke tests for key surfaces |

---

<div align="center">

[Contributing](CONTRIBUTING.md) &nbsp;·&nbsp; [Code of Conduct](CODE_OF_CONDUCT.md) &nbsp;·&nbsp; [Security](SECURITY.md) &nbsp;·&nbsp; [License](LICENSE) &nbsp;·&nbsp; [Architecture](docs/ARCHITECTURE.md) &nbsp;·&nbsp; [Product Bible](docs/PRODUCT_BIBLE.md)

<br>

<sub>NOCTO — signal over noise.</sub>

<br><br>

</div>

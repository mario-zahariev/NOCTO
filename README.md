# NOCTO

NOCTO is a premium iOS nightlife intelligence app focused on Sofia venues.

## Current Scope

- Venue discovery and details
- Favorites persistence
- City map with venue annotations
- Night pulse dashboard
- Local JSON data source with validation and error handling

## Tech Stack

- SwiftUI
- MapKit
- Firebase packages configured in Xcode project (optional runtime setup)

## Quick Start

1. Open `NOCTO.xcodeproj` in Xcode.
2. Replace `NOCTO/GoogleService-Info.plist` with real Firebase credentials (or keep placeholder if Firebase is not used).
3. Build and run target `NOCTO` on iOS simulator/device.

## Data Contract

Venue data is loaded from `venues.json` and validated before use.

Required fields:
- `id` (UUID)
- `name`
- `type` (`club|bar|lounge|event|other`)
- `latitude`, `longitude`
- `address`
- `workingHours`

## Quality Controls

- Unit tests for JSON decoding and validation (Swift Package core module)
- CI workflow for lint/build/test checks
- Dependabot for dependency updates
- Security policy and contribution rules

## Roadmap

- Expand venue ingestion from remote backend
- Add richer admin analytics and moderation flows
- Add snapshot/UI testing

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
- Local JSON data source via `NOCTOCore`

## Project Structure

- `NOCTO/` iOS app target (views, app entry, repository, managers, theme/helpers)
- `Sources/NOCTOCore/` package core module (`NOCTOCore`) for reusable decoding/validation logic
- `Tests/NOCTOCoreTests/` unit tests for core decoding and validation paths

## Quick Start

1. Open `NOCTO.xcodeproj` in Xcode.
2. Keep `NOCTO/GoogleService-Info.plist` as placeholder in the repository. Do not commit real Firebase credentials; use a local-only copy or CI secret-managed injection when Firebase is enabled.
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

- Unit tests for JSON decoding and validation in the package core module (`NOCTOCore`)
- CI workflow for lint/build/test checks
- Firebase detachment guard for project linkage and placeholder config
- Dependabot for dependency updates
- Security policy and contribution rules

## Roadmap

- Expand venue ingestion from remote backend
- Add richer admin analytics and moderation flows
- Add snapshot/UI testing

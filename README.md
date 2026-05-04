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
- Local-first venue data through `NOCTOCore`
- Firebase detached until a real remote data path is implemented

## Project Structure

- `NOCTO/` iOS app target (views, app entry, repository, managers, theme/helpers)
- `Sources/NOCTOCore/` package core module (`NOCTOCore`) for reusable decoding/validation logic
- `Tests/NOCTOCoreTests/` unit tests for core decoding and validation paths

## Quick Start

1. Open `NOCTO.xcodeproj` in Xcode.
2. Build and run target `NOCTO` on iOS simulator/device.
3. If Firebase is intentionally re-enabled later, copy `NOCTO/GoogleService-Info.plist.example` to a local-only `NOCTO/GoogleService-Info.plist`. Do not commit real Firebase credentials.

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
- Firebase detachment guard to prevent accidental package/resource relinkage
- Dependabot for dependency updates
- Security policy and contribution rules

## Roadmap

- Expand venue ingestion from remote backend
- Add richer admin analytics and moderation flows
- Add snapshot/UI testing

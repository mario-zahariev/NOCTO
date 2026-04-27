# Architecture Overview

## Layers

1. Presentation (`NOCTO/*.swift` view files)
2. Domain model (`Venue`)
3. Data access (`VenueRepository`)
4. Cross-cutting utilities (`Haptics`, `LocationManager`, theme/extensions)

## Data Flow

1. `ContentView` requests venues via `VenueRepository`.
2. Repository decodes `venues.json` and validates entries.
3. Views render validated venues and user actions are delegated to `FavoritesManager`.
4. Favorites persist through `UserDefaults` by venue UUID.

## Guardrails

- Fail fast with explicit, typed repository errors.
- Validate all external JSON input before rendering.
- Keep UI and data loading concerns separated.

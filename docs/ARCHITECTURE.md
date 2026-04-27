# Architecture Overview

## Layers

1. Presentation (`NOCTO/*.swift` view files)
2. Domain model (`Venue`)
3. Data access (`VenueRepository`)
4. State and persistence (`FavoritesManager` with `UserDefaults` for favorite UUID storage)
5. Cross-cutting utilities (`Haptics`, `LocationManager`, theme/extensions)

## Data Flow

1. `ContentView` requests venues via `VenueRepository`.
2. `VenueRepository` decodes `venues.json`, validates entries, and returns clean venue payloads.
3. `ContentView`, `HomeView`, and `FavoritesView` call `FavoritesManager` for favorite state mutations/reads.
4. `FavoritesManager` persists favorite venue UUIDs in `UserDefaults`.
5. `VenueRepository` and `FavoritesManager` stay decoupled and are composed by `ContentView`.

## Guardrails

- Fail fast with explicit, typed repository errors.
- Validate all external JSON input before rendering.
- Keep UI and data loading concerns separated.

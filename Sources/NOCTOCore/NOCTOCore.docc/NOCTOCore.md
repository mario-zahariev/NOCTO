# ``NOCTOCore``

Typed venue decoding and validation for NOCTO.

## Overview

NOCTOCore owns the local venue data contract used by the app. It decodes venue
records from JSON, validates required runtime fields, filters invalid entries,
and reports data failures with explicit repository errors.

The package is intentionally local-first. Remote providers should enter through
an app-level `VenueDataSource` adapter and keep Firebase or other backend SDKs
outside this package unless that contract is reviewed.

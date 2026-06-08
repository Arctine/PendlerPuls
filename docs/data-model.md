# Data Model

## User

- `Id`: internal UUID
- `Email`: normalized unique login
- `PasswordHash` and `PasswordSalt`: PBKDF2 output, never the original password
- `CreatedAtUtc`

## Session

- `Id`: internal UUID
- `TokenHash`: SHA-256 hash of the cookie token
- `ExpiresAtUtc`
- `UserId`: owner

The raw session token exists only in the browser cookie.

## SavedJourney

- Human-readable name
- Origin and destination names, Entur IDs, latitude, and longitude
- `UserId`: owner
- Creation timestamp

Coordinates are stored because Entur's journey query accepts coordinates and a
place label. Entur IDs are retained for traceability and future stop-specific
features.

## JourneyObservation

- Reference to one saved journey
- Collection timestamp
- Expected start and end
- Duration and delay in minutes
- Transport line summary

Observations are append-only in the MVP. This makes the reliability history
easy to explain and query.


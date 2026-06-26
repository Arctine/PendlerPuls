# Project Handoff

## Current State

PendlerPuls version `0.2.1` is implemented and published at:

`https://github.com/Arctine/PendlerPuls`

The `main` branch contains the complete MVP. GitHub Actions builds and tests the
backend and frontend.

Windows users can start the complete local application by double-clicking
`START-PENDLERPULS.cmd` and stop it with `STOP-PENDLERPULS.cmd`.

## Implemented User Flow

1. Search for an origin and destination.
2. Preview the next Entur journey.
3. Register or sign in.
4. Save the selected journey.
5. Collect one observation from current live data.
6. Review the latest result, average delay, sample count, on-time rate, trend,
   simple sample score, and recent observation bars.
7. Export observations as CSV.
8. Delete the saved journey or sign out.

## Last Verification

Verified on June 26, 2026:

- eight backend tests passed
- .NET formatting verification passed
- Render PostgreSQL connection-string resolution was fixed and covered by tests

Verified on June 21, 2026:

- six backend tests passed
- five frontend tests passed
- frontend production build passed
- .NET formatting verification passed
- production Dockerfile was not built locally because Docker was not installed
  or not on PATH in this environment

Previously verified on June 8, 2026:

- live Oslo S to Blindern flow passed through the Vite proxy
- registration, cookie session, save, refresh, list, and delete passed
- one-command launcher start, repeated-start handling, and tracked stop passed
- GitHub Actions passed on `main`

## Recommended Next Task

Deploy the single-service Docker setup to a public host and connect it to a
custom subdomain or portfolio project card.

Before treating the deployment as production-grade:

1. Add versioned Entity Framework migrations for persistent production data.
2. Add integration tests for endpoint authentication and ownership.
3. Add rate limiting and production secret management.
4. Add a scheduled collector only after defining API traffic and retention
   rules.

## Known Non-Goals

- PendlerPuls is not a ticketing application.
- It does not implement a route planning algorithm.
- It does not claim that a few manual observations are statistically complete.

## Starting a New Chat

Tell the new chat to read:

1. `AGENTS.md`
2. `README.md`
3. this file
4. `docs/architecture.md`
5. the document related to the requested change

That provides enough context to continue without relying on prior conversation
history.

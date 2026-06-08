# Project Handoff

## Current State

PendlerPuls version `0.1.0` is implemented and published at:

`https://github.com/Arctine/PendlerPuls`

The `main` branch contains the complete MVP. GitHub Actions builds and tests the
backend and frontend.

## Implemented User Flow

1. Search for an origin and destination.
2. Preview the next Entur journey.
3. Register or sign in.
4. Save the selected journey.
5. Collect one observation from current live data.
6. Review the latest result, average delay, and sample count.
7. Delete the saved journey or sign out.

## Last Verification

Verified on June 8, 2026:

- four backend tests passed
- three frontend tests passed
- frontend production build passed
- npm audit reported zero vulnerabilities
- .NET formatting verification passed
- live Oslo S to Blindern flow passed through the Vite proxy
- registration, cookie session, save, refresh, list, and delete passed
- GitHub Actions passed on `main`

## Recommended Next Task

Add versioned Entity Framework migrations for both supported database providers.
This is the most important step before deploying with persistent production
data.

After migrations:

1. Add integration tests for endpoint authentication and ownership.
2. Deploy the Docker stack to a host with HTTPS.
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


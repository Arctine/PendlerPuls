# PendlerPuls Agent Guide

This file is the starting point for another coding assistant or developer.
Read it together with `README.md` and `docs/handoff.md` before changing code.

## Project Goal

PendlerPuls is a student portfolio project that checks live Norwegian public
transport journeys and stores user-triggered reliability observations.

The project should remain understandable to a bachelor-level student. Prefer
clear names, small classes, explicit behavior, and short explanations over
enterprise-style abstraction.

## Repository Map

- `apps/api`: ASP.NET Core 10 minimal API
- `apps/web`: React 19 and TypeScript client
- `tests/api`: xUnit backend tests
- `docs`: design, setup, operations, security, and reflection
- `.github/workflows/ci.yml`: build and test workflow
- `docker-compose.yml`: PostgreSQL, API, and Nginx web deployment

## Important Boundaries

- The browser calls PendlerPuls through `/api`.
- Only the backend calls Entur.
- Authentication uses an opaque HTTP-only cookie and a server-side session.
- Every saved journey query must include the signed-in user's ID.
- SQLite is the zero-setup local provider.
- PostgreSQL is the container/deployment provider.

## Verification Commands

```powershell
dotnet restore
dotnet test .\PendlerPuls.sln --configuration Release
npm install --prefix .\apps\web
npm test --prefix .\apps\web
npm run build --prefix .\apps\web
dotnet format .\PendlerPuls.sln --verify-no-changes --no-restore
```

## Files That Must Stay Local

Do not commit:

- `.env` files containing real credentials
- SQLite databases and WAL files
- runtime logs
- session cookies or tokens
- `bin`, `obj`, `node_modules`, `dist`, or coverage output

The repository documents logs and configuration in `docs/operations.md`.
Generated runtime evidence belongs in CI or issue attachments, not source
control.

## Current Limitations

- The database schema uses `EnsureCreated`, not versioned migrations.
- Observations are collected manually when the user refreshes a saved route.
- There is no password reset, email verification, or rate limiting.
- The app has source code and deployment configuration but no hosted production
  URL yet.

## Change Style

- Keep documentation honest about what is implemented.
- Add tests when changing authentication, ownership, Entur mapping, or database
  behavior.
- Update `docs/api.md` when endpoint contracts change.
- Update `docs/handoff.md` when current status or the next recommended task
  changes.


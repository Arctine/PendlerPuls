# Changelog

## 0.2.1 - 2026-06-26

- Fixed Render PostgreSQL startup by preferring `DATABASE_URL` over the local
  appsettings fallback connection string
- Added tests for hosted PostgreSQL connection-string resolution
- Added Render database startup troubleshooting notes

## 0.2.0 - 2026-06-21

- Added saved-route analytics with sample score, on-time rate, best/worst delay,
  trend, and recent observation bars
- Added CSV export for saved journey observations
- Added a production Dockerfile that serves the React app and API from one
  ASP.NET Core service
- Added a Render Blueprint for one public web service and managed PostgreSQL
- Added deployment and portfolio integration documentation

## 0.1.1 - 2026-06-08

- Added one-action Windows start and stop launchers
- Added dependency checks, readiness checks, local logs, and tracked cleanup
- Updated setup and operations documentation

## 0.1.0 - 2026-06-08

Initial portfolio release.

- Added Entur location search and live journey preview
- Added registration, login, logout, and server-side sessions
- Added saved journeys and reliability observations
- Added SQLite and PostgreSQL support
- Added React dashboard and responsive styling
- Added backend and frontend tests
- Added Docker Compose and GitHub Actions CI
- Added architecture, data model, decisions, reflection, and handoff documents

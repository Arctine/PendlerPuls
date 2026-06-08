# PendlerPuls

PendlerPuls is a full-stack student project for checking a public transport
journey and recording how reliable it is over time. It uses live journey data
from Entur, keeps saved journeys in a relational database, and presents the
result in a responsive React dashboard.

The project was chosen to fill a gap in my portfolio. My other projects already
show Android, desktop, game, and static web development. PendlerPuls focuses on
backend development, data modelling, external APIs, authentication, testing,
containers, and CI.

## Current Features

- Search Norwegian stops and places through Entur's geocoder
- Preview a live journey with duration, expected delay, and transport lines
- Register and sign in with an HTTP-only cookie session
- Save journeys and collect reliability observations
- Review recent delay history for each saved journey
- Run locally with SQLite without installing a database server
- Switch to PostgreSQL through configuration
- Build the API and web client in GitHub Actions

## Technology

| Area | Choice |
| --- | --- |
| Backend | ASP.NET Core 10 minimal API |
| Frontend | React 19, TypeScript, Vite |
| Data | Entity Framework Core, SQLite locally, PostgreSQL in containers |
| External data | Entur Geocoder and Journey Planner v3 |
| Tests | xUnit and Vitest |
| Delivery | Docker Compose and GitHub Actions |

.NET 10 is an active LTS release. The frontend deliberately uses Vite 6 because
the development machine currently has Node 20.18, which is below the requirement
of newer Vite releases.

## Run Locally

Requirements:

- .NET 10 SDK
- Node.js 20 or newer

```powershell
dotnet restore
npm install --prefix .\apps\web
dotnet run --project .\apps\api
```

In a second terminal:

```powershell
npm run dev --prefix .\apps\web
```

Open `http://localhost:5173`. The API runs on `http://localhost:5050`.
SQLite data is stored in `apps/api/pendlerpuls.db`.

## Run With PostgreSQL

Docker is optional for local development. When Docker is available:

```powershell
docker compose up --build
```

The web app is then available at `http://localhost:8080`.

## Repository Structure

```text
apps/
  api/                 ASP.NET Core API and persistence
  web/                 React client
tests/
  api/                 Backend unit tests
docs/
  adr/                 Short architecture decision records
  architecture.md      Components and request flow
  data-model.md        Database entities and relationships
  project-brief.md     Scope, users, and success criteria
  reflection.md        What I learned and what I would improve
```

## Honest Limitations

- The project currently creates the database schema on startup. Versioned EF
  migrations are the next database task before a public production deployment.
- Reliability observations are collected when a signed-in user refreshes a
  saved journey. A scheduled background collector is planned.
- Authentication is intentionally small: email, PBKDF2 password hashing, and
  opaque server-side sessions. Password reset and email verification are not
  included yet.
- Entur data can be unavailable or incomplete. PendlerPuls shows an error
  instead of inventing a result.

## Data Attribution

Transport data is made available by Entur under the Norwegian Licence for Open
Government Data (NLOD). PendlerPuls identifies itself with the required
`ET-Client-Name` request header.

## Documentation

Start with [docs/project-brief.md](docs/project-brief.md), then read
[docs/architecture.md](docs/architecture.md) and
[docs/reflection.md](docs/reflection.md).


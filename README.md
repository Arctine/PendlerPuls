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

## How It Works

1. The user searches for two Norwegian places in the React client.
2. The ASP.NET Core API sends the search to Entur with the required client
   identification header.
3. Entur returns the next journey. PendlerPuls reduces the large provider
   response to duration, delay, lines, modes, and expected times.
4. A signed-in user can save the origin and destination.
5. Each manual refresh stores one observation in the database.
6. The dashboard shows the latest result, average delay, and sample count.

PendlerPuls does not calculate routes itself and does not sell tickets. Entur is
the source of journey and real-time information.

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

### Easy Windows Start

Double-click:

```text
START-PENDLERPULS.cmd
```

The launcher prepares missing dependencies, starts both parts of the app, waits
until they are ready, and opens `http://127.0.0.1:5173`.

When finished, double-click:

```text
STOP-PENDLERPULS.cmd
```

The first start takes longer because project dependencies may need to be
installed. Later starts are faster.

### Manual Start

The launcher above runs the following development setup for you:

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
scripts/               One-command Windows start and stop scripts
docs/
  adr/                 Short architecture decision records
  api.md               HTTP endpoint reference
  architecture.md      Components and request flow
  data-model.md        Database entities and relationships
  development.md       Setup, workflow, and troubleshooting
  handoff.md           Current state and continuation guide
  operations.md        Configuration, logs, data, and deployment notes
  project-brief.md     Scope, users, and success criteria
  reflection.md        What I learned and what I would improve
  security.md          Security choices and remaining risks
  testing.md           Test strategy and verification commands
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

For a quick introduction, start with
[docs/project-brief.md](docs/project-brief.md).

For development or a new chat, read [AGENTS.md](AGENTS.md) and
[docs/handoff.md](docs/handoff.md), followed by:

- [Architecture](docs/architecture.md)
- [API reference](docs/api.md)
- [Data model](docs/data-model.md)
- [Development guide](docs/development.md)
- [Testing](docs/testing.md)
- [Operations and logging](docs/operations.md)
- [Security](docs/security.md)
- [Reflection](docs/reflection.md)

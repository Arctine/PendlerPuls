# Development Guide

## Requirements

- .NET 10 SDK
- Node.js 20 or newer
- Internet access for Entur requests
- Docker only when testing the PostgreSQL stack

## First Setup

On Windows, the easiest option is to double-click
`START-PENDLERPULS.cmd`. It performs setup and starts both applications.
Double-click `STOP-PENDLERPULS.cmd` when finished.

The PowerShell equivalent, useful when a browser should not open, is:

```powershell
.\scripts\Start-PendlerPuls.ps1 -NoBrowser
```

Manual setup remains available:

```powershell
dotnet restore
npm install --prefix .\apps\web
```

Start the API:

```powershell
dotnet run --project .\apps\api
```

Start the frontend in another terminal:

```powershell
npm run dev --prefix .\apps\web
```

Open `http://localhost:5173`.

The launcher stores temporary process information and current logs under
`.run/`. That directory is ignored by Git.

## Configuration

The default local configuration uses SQLite. Environment variable names are
shown in `.env.example`.

To select PostgreSQL:

```powershell
$env:DATABASE_PROVIDER = "Postgres"
$env:ConnectionStrings__Postgres = "Host=localhost;Port=5432;Database=pendlerpuls;Username=pendlerpuls;Password=pendlerpuls"
```

The credentials in examples and Docker Compose are local development defaults,
not production secrets.

## Useful Files

- `apps/api/Program.cs`: dependency registration and endpoint mapping
- `apps/api/Endpoints`: HTTP behavior
- `apps/api/Services/EnturClient.cs`: external provider integration
- `apps/api/Data/AppDbContext.cs`: relationships and indexes
- `apps/web/src/App.tsx`: main page workflow
- `apps/web/src/api.ts`: browser API client

## Troubleshooting

### The frontend cannot reach the API

Confirm that the API is listening on port `5050`. Vite proxies `/api` there.

If a previous launcher session ended unexpectedly, run
`STOP-PENDLERPULS.cmd`, then start again. If either port belongs to another
program, the launcher refuses to stop that unrelated program.

### Entur returns an error

Confirm internet access and the `Entur__ClientName` value. The API must identify
itself using Entur's required `ET-Client-Name` header.

### Local data needs to be reset

Stop the API and delete `apps/api/pendlerpuls.db`. The schema is recreated on
the next start. This deletes all local accounts and journeys.

### Docker does not work

Docker is optional. Use the SQLite instructions unless Docker Desktop or another
compatible Docker engine is installed.

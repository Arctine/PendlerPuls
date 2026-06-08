# Operations and Logging

## Runtime Configuration

Important values:

- `DATABASE_PROVIDER`: `Sqlite` or `Postgres`
- `ConnectionStrings__Postgres`: PostgreSQL connection string
- `Entur__ClientName`: identifier sent to Entur
- `VITE_API_BASE_URL`: optional browser API base URL

Real production credentials must be supplied by the deployment platform and
must not be committed.

## Logging

The API uses standard ASP.NET Core structured console logging.

It records:

- application startup and shutdown
- outgoing Entur request status and duration
- provider GraphQL errors
- unhandled server exceptions

It should not record:

- passwords
- raw session tokens
- cookies
- database connection passwords

Local console output is temporary. Docker can collect it with:

```powershell
docker compose logs api
docker compose logs web
docker compose logs database
```

Runtime log files are excluded by `.gitignore`. Logs can contain environment
details and user information, grow quickly, and become stale. Important defects
should be represented by tests, issue descriptions, or sanitized excerpts
instead of committing full logs.

## Health Check

`GET /api/health` confirms that the API process is responding. It does not
currently test Entur or database connectivity.

## Data

SQLite local data is stored in `apps/api/pendlerpuls.db` and is ignored by Git.
Docker Compose stores PostgreSQL data in the `postgres-data` volume.

Backups and retention are not implemented in version `0.1.0`.

## Deployment Notes

Docker Compose exposes Nginx on port `8080`. Nginx serves the React build and
proxies `/api` to the API container.

Before a public deployment:

- replace development database credentials
- provide HTTPS
- add versioned migrations
- define backup and retention rules
- add rate limiting
- review cookie settings behind the selected reverse proxy


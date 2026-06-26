# Deployment Guide

This project can run locally with SQLite, in Docker Compose with PostgreSQL, or
as one hosted web service backed by a managed PostgreSQL database.

The hosted setup is intentionally simple because this is a portfolio project:
one public app URL, one database, and no separate frontend/API domains.

## Recommended Public Shape

```text
Browser
  |
  | https://pendlerpuls.example.com
  v
ASP.NET Core web service
  | serves React files from wwwroot
  | handles /api requests
  v
Managed PostgreSQL database
```

This shape avoids cross-site cookie problems because the React frontend and API
are served from the same origin.

## Files Used For Hosting

- `Dockerfile`: builds React, copies the build into the API, and runs ASP.NET
  Core on port `8080`
- `render.yaml`: Render Blueprint for one Docker web service and one PostgreSQL
  database
- `apps/api/Program.cs`: serves static files in production and keeps `/api`
  endpoints active

## Render Deployment Checklist

1. Push the repository to GitHub.
2. Create a Render Blueprint from the repository root.
3. Render reads `render.yaml` and creates:
   - `pendlerpuls`: Docker web service
   - `pendlerpuls-db`: PostgreSQL database
4. Wait for the first build and deploy.
5. Open the Render-provided `onrender.com` URL.
6. Confirm `/api/health` returns `ok`.
7. Register a test account, save a route, refresh it, and export CSV.

## Important Environment Values

The Blueprint sets:

- `ASPNETCORE_ENVIRONMENT=Production`
- `ASPNETCORE_URLS=http://+:8080`
- `DATABASE_PROVIDER=Postgres`
- `DATABASE_URL` from the managed database connection string
- `Entur__ClientName=arctine-pendlerpuls`

Do not commit real production secrets. Add provider-specific secrets through the
hosting dashboard.

## Troubleshooting Render Database Startup

If the deploy log says:

```text
Failed to connect to 127.0.0.1:5432
```

the app is trying to use the local development PostgreSQL connection string
instead of Render's managed database URL.

Check that the web service has:

- `DATABASE_PROVIDER=Postgres`
- `DATABASE_URL` populated from the Render PostgreSQL database

The application prefers `DATABASE_URL` when it is present and only falls back to
`ConnectionStrings:Postgres` for local or manual deployments.

## Custom Domain

After the Render URL works, add a custom domain such as:

```text
pendlerpuls.yourdomain.com
```

The usual flow is:

1. Add the custom domain to the hosted web service.
2. Add the DNS record requested by the hosting provider.
3. Wait for DNS propagation.
4. Verify the domain in the hosting dashboard.
5. Confirm HTTPS works.
6. Link to the custom domain from the portfolio website.

Using a subdomain is cleaner than embedding the whole app inside an existing
portfolio page. The portfolio can show a project card and link to the live app.

## Production Gaps To Fix Later

Before relying on the app for real users, add:

- Entity Framework migrations instead of `EnsureCreated`
- endpoint integration tests for authentication and ownership
- rate limiting
- stronger secret management documentation
- backups and retention rules
- a scheduled collector if automatic observations become part of the scope

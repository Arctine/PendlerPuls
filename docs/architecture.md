# Architecture

PendlerPuls is a small monorepo with two deployable applications.

```text
Browser
  |
  | HTTP + session cookie
  v
React web client
  |
  | /api
  v
ASP.NET Core API
  |              \
  | EF Core       \ HTTPS + ET-Client-Name
  v                v
SQLite/Postgres   Entur APIs
```

## Backend Responsibilities

- Validate browser input
- Keep the Entur client name server-side
- Translate Entur responses into a small stable contract
- Hash passwords and manage opaque sessions
- Enforce journey ownership
- Store observations in a relational database

## Frontend Responsibilities

- Accessible forms and feedback
- Location autocomplete
- Journey preview and saved journey views
- Session-aware navigation
- No direct database or Entur access

## Error Strategy

Expected validation errors return `400`. Missing authentication returns `401`.
Missing owned resources return `404`. Entur failures return `502` so callers can
distinguish an upstream problem from a PendlerPuls server error.

## Why This Is Not Split Into More Services

The current scope does not need microservices. One API keeps deployment,
debugging, and data consistency understandable for a student project. The Entur
client and endpoint groups are separate classes, so they can be extracted later
if there is a real scaling or ownership reason.


# API Reference

The local base URL is `http://localhost:5050/api`. During frontend development,
Vite proxies `/api` to that address.

JSON request and response property names use camel case.

## Health

### `GET /api/health`

Returns the API name, current UTC time, and an `ok` status.

## Transit

### `GET /api/transit/locations?query=Oslo%20S`

Searches Entur's geocoder. The query must contain at least two characters.

Each result contains:

- Entur ID
- name and display label
- latitude and longitude

### `POST /api/transit/preview`

Accepts selected `from` and `to` location objects and returns the next journey:

- expected start and end time
- duration in minutes
- delay in minutes
- transport modes
- public line summary
- Entur attribution

Entur failures return `502`.

## Authentication

### `POST /api/auth/register`

Creates an account and session. Requires a valid email and a password between
10 and 200 characters.

### `POST /api/auth/login`

Verifies credentials and creates a new session.

### `GET /api/auth/me`

Returns the current user. Returns `401` without a valid session cookie.

### `POST /api/auth/logout`

Deletes the current server-side session and browser cookie.

## Saved Journeys

All journey endpoints require a valid session.

### `GET /api/journeys/`

Returns only journeys owned by the current user. Each journey includes up to
the 12 most recent observations.

### `POST /api/journeys/`

Saves a journey name, origin, and destination for the current user.

### `POST /api/journeys/{id}/refresh`

Requests a new live journey from Entur and appends one reliability observation.

### `DELETE /api/journeys/{id}`

Deletes a journey owned by the current user. Another user's ID returns `404`
rather than revealing that the resource exists.

## Status Codes

- `200`: successful read or update
- `201`: account or journey created
- `204`: successful logout or deletion
- `400`: invalid input
- `401`: authentication required or credentials rejected
- `404`: owned resource not found
- `409`: email already registered
- `502`: Entur did not provide a usable response


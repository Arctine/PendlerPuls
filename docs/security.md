# Security Notes

## Implemented

- Passwords use PBKDF2 with SHA-256, a random salt, and 120,000 iterations.
- The browser receives an opaque random session token.
- Only a SHA-256 hash of that token is stored in the database.
- The session cookie is HTTP-only, `SameSite=Lax`, and secure outside
  development.
- Saved journey reads, updates, and deletes are filtered by the current user.
- Entur calls are made by the backend rather than exposing provider integration
  details to the browser.

## Not Yet Implemented

- email verification
- password reset
- login or API rate limiting
- multi-factor authentication
- security headers beyond framework defaults
- CSRF tokens for state-changing endpoints
- session management UI
- automated dependency update tooling

`SameSite=Lax` reduces cross-site request risk, but a public deployment should
review CSRF protection together with the final hosting domains and proxy.

## Secrets

The repository contains only local example credentials. Real database
passwords, tokens, and environment files must remain outside source control.

## Reporting

For a portfolio project, security findings should be opened privately with the
repository owner rather than posted with live credentials or user data.


# ADR 0002: Access Entur Through the Backend

## Status

Accepted

## Decision

The browser calls PendlerPuls, and PendlerPuls calls Entur.

## Reason

This keeps provider-specific GraphQL and headers out of the UI, gives the
frontend a smaller stable contract, and creates one place for validation,
timeouts, logging, and future caching.


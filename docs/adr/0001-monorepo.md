# ADR 0001: Keep API and Web Client in One Repository

## Status

Accepted

## Decision

The ASP.NET Core API and React client live in one repository.

## Reason

The project has one developer, one product, and contracts that change together.
A monorepo makes local setup and CI easier without preventing separate
deployments.


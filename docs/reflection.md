# Reflection

## What This Project Demonstrates

PendlerPuls connects several topics that are often taught separately:

- HTTP API design
- Relational modelling
- Authentication and ownership checks
- Integration with an external GraphQL API
- React state and accessible form design
- Automated tests, CI, and container configuration

## Decisions I Would Revisit

`EnsureCreated` keeps the first local run simple, but a deployed system needs
versioned migrations. I would add provider-tested migrations before inviting
real users.

The reliability sample is user-triggered. A background service would create a
more useful and less biased dataset, but it also raises questions about API
traffic, schedules, retention, and how to define comparable journeys.

The authentication system is deliberately narrow. A mature product would add
email verification, password reset, session management, rate limiting, and a
documented privacy policy.

## Main Learning Point

The difficult part was not displaying a delay number. It was deciding where
external data should enter the system, how much of the provider response to
expose, and how to keep the application useful when the provider is unavailable.


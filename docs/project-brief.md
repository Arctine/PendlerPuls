# Project Brief

## Problem

Journey planners answer "when should I leave?" but they do not make it easy to
answer "how reliable is the journey I take every week?" PendlerPuls lets a user
check a live journey, save it, and build a small history of delay observations.

## Target User

The first target user is a student or commuter in Norway who repeats the same
journeys and wants a quick view of expected travel time and recent reliability.

## MVP Scope

The first version should let a user:

1. Search for an origin and destination.
2. Preview the next journey from Entur.
3. Create an account and sign in.
4. Save the journey.
5. Refresh a saved journey and store an observation.
6. Review recent observations.

## Out of Scope

- Ticket sales
- Route planning algorithms implemented by PendlerPuls
- Push notifications
- Social features
- Native mobile clients
- Claims that the collected sample is statistically representative

## Success Criteria

- A new developer can run the project from the README.
- The browser never calls Entur directly; the API owns the integration.
- Passwords are not stored in plain text.
- Saved journeys belong to one user and cannot be read by another user.
- External API failures produce a useful error response.
- Backend and frontend tests run in CI.


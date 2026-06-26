# Portfolio Integration

PendlerPuls should be linked from the existing portfolio website as a live
project, not copied into the portfolio itself.

## Recommended Portfolio Card Text

```text
PendlerPuls

A full-stack public transport reliability app for Norwegian commuters. Users can
search live Entur journeys, save routes, collect delay observations, view simple
route analytics, and export their observation data as CSV.

Built with React, TypeScript, ASP.NET Core, Entity Framework Core, SQLite,
PostgreSQL, Docker, and GitHub Actions.
```

## Suggested Buttons

```text
Live Demo
Source Code
Architecture Notes
```

Use these targets:

- `Live Demo`: `https://pendlerpuls.onrender.com`
- `Source Code`: `https://github.com/Arctine/PendlerPuls`
- `Architecture Notes`: `https://github.com/Arctine/PendlerPuls/blob/main/docs/architecture.md`

## Small HTML Example

```html
<article class="project-card">
  <p class="project-label">Full-stack portfolio project</p>
  <h3>PendlerPuls</h3>
  <p>
    Public transport reliability tracker using live Entur data, authenticated
    saved routes, observation history, analytics, and CSV export.
  </p>
  <ul>
    <li>React + TypeScript frontend</li>
    <li>ASP.NET Core API</li>
    <li>SQLite locally, PostgreSQL for deployment</li>
    <li>Docker and GitHub Actions</li>
  </ul>
  <a href="https://pendlerpuls.onrender.com">Live demo</a>
  <a href="https://github.com/Arctine/PendlerPuls">GitHub</a>
</article>
```

## Interview-Friendly Summary

> PendlerPuls is deployed as one public web app. The React frontend and ASP.NET
> Core API are served from the same domain, which keeps cookie authentication
> simple. The API owns Entur integration and database access, while the frontend
> focuses on route search, journey preview, saved-route analytics, and CSV
> export.

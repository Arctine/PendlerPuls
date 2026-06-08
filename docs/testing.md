# Testing

## Backend

Run:

```powershell
dotnet test .\PendlerPuls.sln --configuration Release
```

Current tests cover:

- accepting the correct password
- rejecting an incorrect password
- mapping an Entur journey response
- appending an observation with SQLite

The Entur mapping test uses a stub HTTP response. It does not depend on the live
provider.

## Frontend

Run:

```powershell
npm test --prefix .\apps\web
npm run build --prefix .\apps\web
```

Current tests cover delay labels, reliability thresholds, and average delay
calculation. The production build performs TypeScript checking and Vite
bundling.

## Formatting

```powershell
dotnet format .\PendlerPuls.sln --verify-no-changes --no-restore
```

## CI

GitHub Actions runs:

1. .NET restore and release build
2. backend tests
3. locked frontend dependency installation
4. frontend tests
5. frontend production build

## Important Test Gaps

- endpoint-level authentication and ownership integration tests
- browser component tests
- PostgreSQL provider tests
- Docker Compose smoke test
- accessibility automation
- timeout and malformed Entur response cases

These gaps are documented rather than implied to be complete.


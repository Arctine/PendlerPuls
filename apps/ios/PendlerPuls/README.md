# PendlerPuls iPhone App

This is a small SwiftUI companion client for the existing PendlerPuls API.

## Open

Open this project in Xcode:

```text
apps/ios/PendlerPuls/PendlerPuls.xcodeproj
```

The app targets iPhone on iOS 17 or newer.

## API URL

The app stores its API base URL in iPhone user defaults. It starts with:

```text
https://pendlerpuls.onrender.com/api
```

For a real iPhone, deploy the backend first with the root `render.yaml`, then
set the app's API URL to the deployed HTTPS `/api` URL.

For the iOS Simulator only, you can point the app at the local API while it is
running:

```text
http://127.0.0.1:5050/api
```

The app keeps the backend's HTTP-only session cookie through `URLSession`, so
register or login should be followed by a successful `/auth/me` session restore
on the next launch.

## Scope

Implemented first-scope flow:

- register and login
- search origin and destination locations
- search stop names, places, and addresses
- preview a journey
- choose between returned journey options when the deployed API supports them
- save a journey
- list saved journeys
- refresh a saved journey and collect an observation
- delete a saved journey
- logout

CSV export, maps, notifications, widgets, and background monitoring are not part
of this first iPhone client.

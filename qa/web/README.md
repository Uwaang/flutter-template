# Minimal runtime smoke gate (SCRUM-435)

This is a deliberately small proof of concept, **not** an exhaustive QA suite.

## What it checks

One Chromium test is run separately against the compiled **Web JS** and **Web WASM** release outputs:

1. The Flutter splash element disappears within 30 seconds.
2. The real authentication screen exposes **Mock Sign In**.
3. No uncaught JavaScript exception was emitted during startup.

A successful `flutter build web`, downloaded bundle, HTTP 200, Flutter canvas
element, or process exit code alone does **not** meet this gate.

## Local execution

From repository root, after Flutter codegen and after **one** web build:

```sh
flutter build web --release -t lib/main_production.dart
# Alternatively: flutter build web --wasm --release -t lib/main_production.dart
cd qa/web
npm install
npx playwright install chromium
npm test
```

The Playwright config serves `../../build/web` on loopback port 8765.
The GitHub Actions job does the prerequisite Flutter preparation and runs
both render modes independently. `qa/web/playwright-report` and
`qa/web/test-results` capture traces and screenshots on failure.

`@playwright/test` has a pinned top-level version. A lockfile has not yet
been generated; do not promote this PoC to a required CI gate without
a reviewed lockfile and stable initial results.

## Explicit exclusions

- No Firebase or Supabase credentials; current builds use CI placeholder
  configuration and can fail at runtime. A **red gate is expected and useful**.
- No automatic fix, skip, retry loop or AI healer in CI.
- No full-browser matrix, screenshot snapshot baselines, mobile emulators or
  seven-platform GUI tests.
- Do not weaken security settings or rewrite startup code just to pass.
- Maestro remains an **evaluation candidate** for Android/iOS; existing Patrol
  tests are kept. Midscene is deferred.

When the startup failures are fixed, add at most one business-critical user
journey (e.g., login) after backend and test-account strategy is chosen.

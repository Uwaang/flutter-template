# Minimal runtime smoke gate (SCRUM-435)

This is a deliberately small proof of concept, **not** an exhaustive QA suite.

## What it checks

One Chromium test is run separately against the compiled **Web JS** and **Web WASM** release outputs:

1. The Flutter splash element disappears within 30 seconds.
2. The real authentication screen exposes **Mock Sign In**.
3. No uncaught JavaScript exception was emitted during startup.

A successful `flutter build web`, downloaded bundle, HTTP 200, Flutter canvas
element, or process exit code alone does **not** meet this gate.

## Verified and optional live check

The regular Web JS and Web WASM first-screen PoC passed on the Supabase-first
branch: [successful run](https://github.com/Uwaang/flutter-template/actions/runs/42788045284).
It uses **no live Supabase credentials** and displays only `Mock Sign In`.

An explicitly opted-in `live-auth.spec.js` additionally passed against a
disposable Supabase test project: [one-time browser E2E](https://github.com/Uwaang/flutter-template/actions/runs/42784400895).
It checks anonymous sign-in, browser reload persistence, sign-out, and
protected-route rejection. The push-triggered **live** workflow was removed
after success to avoid creating accounts on every commit. Live runs must not
publish traces, screenshots, JWTs, refresh tokens, or session storage values.

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

The Playwright config serves `../../build/web` on loopback port 8765 using a tiny SPA fallback server. Since the app uses Flutter's path URL strategy, refreshing `/root-route` (and other client routes) must return `index.html`; nonexistent files still return 404.
The GitHub Actions job does the prerequisite Flutter preparation and runs
both render modes independently. `qa/web/playwright-report` and
`qa/web/test-results` capture traces and screenshots on failure.

`@playwright/test` has a pinned top-level version. A lockfile has not yet
been generated; do not promote this PoC to a required CI gate without
a reviewed lockfile and stable initial results.

## Explicit exclusions

- The standard smoke has no Firebase or Supabase credentials, uses mocked
  first-screen authentication, and must remain **green**. A live Auth run is
  separate, explicit, and may create a real anonymous user.
- No automatic fix, skip, retry loop or AI healer in CI.
- No full-browser matrix, screenshot snapshot baselines, mobile emulators or
  seven-platform GUI tests.
- Do not weaken security settings or rewrite startup code just to pass.
- Maestro remains an **evaluation candidate** for Android/iOS; existing Patrol
  tests are kept. Midscene is deferred.

The optional one-time live anonymous-login journey has been verified. Do not
add more E2E cases or make it a required gate without a specific new failure,
reviewed backend/test-account strategy, and stable locked dependencies.

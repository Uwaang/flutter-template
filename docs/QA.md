# Runtime QA

This is the single guide for the repository's **optional runtime smoke checks**. CI compilation and runtime verification are different; see [CI.md](CI.md). Live Supabase authentication setup and exclusions are documented in [SUPABASE_FIRST.md](SUPABASE_FIRST.md).

## Web JS and Web WASM

This is a deliberately small proof of concept, **not** an exhaustive QA suite.

### What it checks

One Chromium test is run separately against the compiled **Web JS** and **Web WASM** release outputs:

1. The Flutter splash element disappears within 30 seconds.
2. The real authentication screen exposes **Mock Sign In**.
3. No uncaught JavaScript exception was emitted during startup.

A successful `flutter build web`, downloaded bundle, HTTP 200, Flutter canvas
element, or process exit code alone does **not** meet this gate.

### Verified and optional live check

The regular Web JS and Web WASM first-screen PoC passed on the Supabase-first
branch: [successful run](https://github.com/Uwaang/flutter-template/actions/runs/42788045284).
It uses **no live Supabase credentials** and displays only `Mock Sign In`.

An explicitly opted-in `live-auth.spec.js` additionally passed against a
disposable Supabase test project: [one-time browser E2E](https://github.com/Uwaang/flutter-template/actions/runs/42784400895).
It checks anonymous sign-in, browser reload persistence, sign-out, and
protected-route rejection. The push-triggered **live** workflow was removed
after success to avoid creating accounts on every commit. Live runs must not
publish traces, screenshots, JWTs, refresh tokens, or session storage values.

### Local execution

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
The conditional GitHub Actions job does the prerequisite Flutter preparation and runs
both render modes independently when relevant source or configuration changes. `qa/web/playwright-report` and
`qa/web/test-results` capture traces and screenshots on failure.

`@playwright/test` has a pinned top-level version. A lockfile has not yet
been generated; do not promote this PoC to a required CI gate without
a reviewed lockfile and stable initial results.

### Explicit exclusions

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

## Android emulator

One **optional** GitHub Actions run: build a synthetic, debug-signed Android
profile APK, launch it in an API 34 emulator, and assert the visible
`Mock Sign In` screen. This is **not** a required merge/release gate.

- Workflow: `.github/workflows/android-runtime-smoke.yml`; **manual dispatch only** after the workflow exists on the default branch. Normal PRs and `main` pushes do not launch an Android emulator.
- Fixture: `qa/mobile/prepare_ci_env.py` derives SHA-256 signing hash from
  the existing debug keystore and corrects the app ID in generated,
  gitignored `.env*` files. No Firebase or OAuth credentials are supplied.
- Test: `qa/mobile/run_once.sh` checks actual Android UI hierarchy and
  keeps screenshot/logcat evidence.
- Gradle 8.14.3 distribution: checksum pinned in `android/gradle/wrapper/gradle-wrapper.properties`. The official `setup-gradle@v6` cache/validation replacement is awaiting an actual Android smoke run; do not treat it as proven yet.

The optional `qa/mobile/startup.yaml` Maestro example and existing Patrol
tests remain unchanged. No login success, real backend, release signing, iOS
or desktop runtime is verified.

### Verified one-time real Android Auth lifecycle

An Android API 34 emulator passed real Supabase anonymous sign-in, authenticated
Profile, app process force-stop/relaunch with Profile restored, sign-out, and
signed-out relaunch:
[successful job](https://github.com/Uwaang/flutter-template/actions/runs/42785429226).

The temporary `scrum-437-live-android-once.yml` workflow was **deleted after
the success**. `qa/mobile/run_live_auth_once.sh` remains as a manual reference;
it expects a build explicitly configured with a **disposable Supabase project**
and can create a real anonymous Auth account. It must not run against a
production backend or log session tokens. This does **not** validate physical
devices, Google/Apple OAuth, or release signing.

## Shared boundaries

- Regular smoke tests use non-secret mock startup; they do not prove real sign-in or provider OAuth.
- One-time live Auth tests must use a disposable project, be explicitly opted in, and not disclose session tokens, traces or authenticated screenshots.
- Native Windows/macOS/iOS GUI, physical Android devices, production signing, and store submission are not established by existing CI.
- Keep tests focused on an observed failure or important user-visible behavior; do not expand the matrix merely to increase coverage.

## Patrol integration tests

The existing Patrol tests are under `integration_test/`. The repository make target runs `patrol test --flavor develop`:

```sh
make integration_test
```

A few inherited Patrol finder examples (adapt selectors to the current app):

```dart
expect($("Can't touch this"), findsNothing);
expect($(Card), findsNWidgets(3));
await $('Log in').waitUntilVisible();
await $('index: 100').scrollTo(view: $(#listView2).$(Scrollable)).tap();
```

See [Patrol finder documentation](https://patrol.leancode.co/finders/usage) for full syntax. These snippets are examples, **not passing assertions for the current app**. Existing Patrol tests are preserved; optional Playwright and Android smoke checks above remain the documented runtime gates.

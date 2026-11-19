# Flutter Template — Project Overview

This document reflects the current GitHub `main` architecture. The template is a lean starting point rather than an STRV-compatible application.

## Stack and scope
- Flutter SDK pinned in `.fvmrc`; Android, iOS, Web JS/WASM, Linux, Windows and macOS compile targets.
- Material 3 with shared color and type themes, Flutter's native widgets and reusable example components.
- Riverpod with code generation, Freezed, AutoRoute, and SharedPreferences for simple local UI state.
- Optional Supabase Auth using a public project URL and publishable key. Google/Apple use Supabase OAuth; native/desktop callbacks need independent real-device verification.
- No bundled REST API/backend, profile database/CRUD, push/local notification service, threat detection, external analytics or signed release pipeline.

## Starting the app
Entry points `lib/main_develop.dart`, `lib/main_staging.dart`, and `lib/main_production.dart` call `setupApp`:
1. Initialize Flutter, choose flavor and load gitignored `.env` files.
2. Configure Supabase Auth if a URL/key pair is present. Otherwise use the mock-only demo.
3. Apply static-hosting Web routing when selected, desktop window defaults and theme/system-bar settings.
4. Construct `MaterialApp.router` using AutoRoute and the shared Material 3 theme.

Neither secret keys nor real Supabase credentials are injected by public CI. `tool/create_ci_env.dart` writes only empty placeholders for mock builds.

## Main screens and routes
- `LandingRoute`: checks restored Supabase session and routes to authentication or the tab shell.
- `AuthenticationRoute`: Google, Apple and anonymous sign-in with configured Supabase, or Mock Sign In without configuration.
- `RootRoute`: adaptive Home, Events and Profile tabs.
- `EventDetailRoute` and `DebugToolsRoute`: illustrative navigation and Material 3 component examples.

The Debug Tools page includes local widgets, dialogs, typography, theme colors and layout diagnostics. It does not request notification permissions or call remote placeholder endpoints.

## Repository map
- `lib/app/`: app initialization, platform setup, theme and routing.
- `lib/core/supabase/`: auth/client initialization and callback URL handling.
- `lib/core/database/`: SharedPreferences-backed local UI cache.
- `lib/core/riverpod/`: event and async state helpers.
- `lib/common/`: reusable UI pieces, exceptions, extensions, auth use cases and validators.
- `lib/features/`: screens and their Riverpod state.
- `project_setup/`: app identity, icon and splash customizer.
- `tool/`: non-secret CI fixtures and native packaging helpers.
- `qa/` and `test/`: mock/runtime and unit/widget tests.
- `.github/workflows/`: quality, 7-target compile CI, JS/WASM runtime smoke and mock-only Pages previews.

## Working on the template
```sh
make install       # or install the pinned Flutter SDK yourself
make gen
make analyze
make test
make build-web
```

The canonical source is GitHub `main`, with PRs validated by GitHub Actions. Code-generated files are not a substitute for checking the source of truth in `lib/` and `pubspec.yaml`. Release artifacts from CI are compile-only and are not store-signed.

## Boundaries
Real Supabase OAuth E2E was validated for Google on a local Flutter Web QA build, not for every native platform. Public GitHub Pages remains mock-only; no real project keys or user credentials belong in public CI. Supabase Auth is not an application profile database.

Keep the original STRV license and attribution in `LICENSE` and `README.md`. Compatibility with obsolete STRV packages, APIs, Firebase tooling, notification scaffolds and distribution files is not a project goal.

For details, see [CI](CI.md), [QA](QA.md), [Supabase setup](SUPABASE_FIRST.md), and [Project setup](PROJECT_SETUP.md).

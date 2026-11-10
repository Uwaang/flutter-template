# Flutter Template Project Overview

This document is a fast orientation guide for contributors and AI assistants. It explains how the current template is laid out, where important behavior lives, and which parts are examples versus fully wired runtime behavior.

## What This Repository Is
- A cross-platform Flutter application template.
- It ships with example screens, routing, code generation, theming, Supabase Auth, local notification scaffolding, secrets handling, release scaffolding, and project setup utilities.
- It is meant to be customized. Some services are intentionally scaffolded and still marked with TODOs.

## Core Stack
- Flutter with FVM-managed SDK version from `.fvmrc`
- Riverpod and `riverpod_annotation`
- Freezed and `json_serializable`
- AutoRoute
- Dio
- SharedPreferences
- Supabase Auth (`supabase_flutter`), with no Firebase SDK dependencies in the active `pubspec.yaml`
- FlutterGen and `gen-l10n`

## Where To Start Reading
- `pubspec.yaml`: package choices, SDK constraints, assets, fonts, and generators
- `makefile`: common project commands
- `build.yaml`: codegen scope and filename expectations
- `lib/app/setup/setup_app.dart`: startup pipeline and which services are actually enabled
- `lib/app/navigation/app_router.dart`: route graph
- `lib/app/app.dart`: `MaterialApp.router`, provider container, flavor banner, observers

## App Startup Flow
1. Entry points such as `lib/main_develop.dart`, `lib/main_staging.dart`, and `lib/main_production.dart` call `setupApp(flavor: ...)`.
2. `setupApp` initializes Flutter bindings, orientation, flavor configuration, dotenv overrides, optional Supabase Auth, freeRASP security on mobile, web and desktop setup, image cache, theme loading, and system bar theming.
3. `App.startApp()` mounts the shared Riverpod `providerContainer`.
4. `App` builds `MaterialApp.router` with generated localization delegates, theme mode, and analytics route observers.

Important note:
- No URL/key means **mock-only startup**, not a real backend login. A URL or publishable key without the other is a configuration error.
- A live anonymous sign-in creates a real Supabase Auth user, but no application database table is introduced. The local user cache still uses SharedPreferences.
- Google/Apple OAuth provider configuration and native/desktop callback handling must be verified separately.

## Route Map
Defined in `lib/app/navigation/app_router.dart`.

Current top-level routes:
- `LandingRoute` as the initial route
- `AuthenticationRoute`
- `RootRoute`
- `EventDetailRoute`
- `DebugToolsRoute`

`RootRoute` is the tab shell and currently contains:
- `HomeRoute`
- `EventsRoute`
- `ProfileRoute`

## Feature Inventory
Current feature folders under `lib/features/`:
- `authentication`: sign-in flow, state, and one-off events
- `debug_tools`: sample pages for colors, text styles, widgets, and actions
- `event_detail`: event detail example screen
- `events`: events listing example screen
- `home`: example home screen
- `landing`: startup redirect logic and force-update content
- `profile`: profile screen, state, and sign-out event flow
- `root`: tab shell using `AutoTabsScaffold`

## Code Organization

### `lib/app`
- `configuration/`: flavor-specific runtime configuration
- `navigation/`: AutoRoute configuration and generated router files
- `setup/`: startup and platform-specific initialization
- `theme/`: color scheme, text theme, and system bar theming

### `lib/common`
- `animation/`: shared animations
- `component/`: smaller reusable widgets
- `composition/`: larger UI compositions such as dialogs and placeholders
- `data/`: DTOs, enums, entities, and exceptions
- `extension/`: build context and model helpers
- `provider/`: shared service providers such as theme mode, current user and local notifications; leftover Firebase-named files are not enabled SDK services
- `usecase/`: Riverpod-based IO or domain actions
- `validator/`: validation controllers and validation state models

### `lib/core`
- `analytics/`: analytics and crash logging helpers
- `database/`: local SharedPreferences wrapper (no remote SQL/CRUD)
- `supabase/`: Supabase Auth initialization/session handling
- `network/`: Dio setup and Auth-token interceptor
- `riverpod/`: event and async state helper mixins

Useful distinction:
- `component/` is for reusable UI primitives.
- `composition/` is for bigger assembled sections built from primitives.

## Common Screen Pattern
Many stateful screens follow this shape:
- `*_page.dart` for route widget and page-level listeners
- `*_page_content.dart` for the main widget tree
- `*_state.dart` for the `freezed` state model and `@riverpod` notifier
- `*_event.dart` for one-off event unions consumed by the page

This is a strong pattern in the template, but not every feature uses every file.

## UI And Theme Conventions
- Shared widgets live in `lib/common/component/` and `lib/common/composition/`.
- `CustomAppBar` is used widely.
- Theme and localization are typically accessed through `BuildContext` extensions.
- `CustomSystemBarsTheme` handles edge-to-edge system UI configuration.
- The template currently uses plain `Scaffold` widgets directly. There is no shared `CustomScaffold` in the current codebase.

## State And Data Flow
Typical feature flow:
1. A page or content widget reads a Riverpod provider.
2. A feature notifier manages `AsyncValue<State>` and may emit one-off events through `EventNotifier`.
3. Notifiers call Riverpod use cases from `lib/common/usecase/`.
4. Use cases talk to shared services such as `dioProvider` or SharedPreferences wrappers.
5. DTOs are mapped into entities before being exposed to UI.

Helpers worth knowing:
- `lib/core/riverpod/state_handler.dart`
- `lib/core/riverpod/event_notifier.dart`
- `lib/common/extension/async_value.dart`

## Auth And Notifications
- Supabase Auth is the sole built-in backend when its public project URL and publishable key are configured.
- Anonymous sign-in, session restoration, logout and bearer tokens are wired through use cases; OAuth uses provider redirect + auth-state events, but real Google/Apple OAuth provider E2E has not been verified.
- Local notification payload/display helpers remain, but FCM, Firebase Auth, Crashlytics, Analytics and Remote Config are not active SDK integrations.
- No application database schema/CRUD, remote profile table, Storage, or Edge Functions are implemented in SCRUM-437.

## Localization And Generated Assets
- ARB source files live in `assets/localization/`.
- Generated localization and asset files are written to `lib/assets/`.
- Fonts and asset declarations are owned by `pubspec.yaml`.
- `make gen` runs both localization generation and build runner generation.

## Commands That Matter
- `make gen`: localization plus code generation
- `make watch`: continuous build runner
- `make test`: wrapper around `fvm flutter test`
- `make integration_test`: Patrol integration tests
- `make generateAndroidProductionAppBundle`
- `make generateIosDevelopIpa`
- `make generateIosStagingIpa`
- `make generateIosProductionIpa`

## Versioning And Releases

- GitHub hosted compile checks and the selected-branch publication policy are documented in `docs/PUBLIC_CI.md`. Personal Windows provisioning stays on the private lab branch.
- Flutter SDK pinning is managed through `.fvmrc`.
- App versioning and Flutter constraints are declared in `pubspec.yaml`.
- The repo includes `release_notes.txt` plus build commands for Android and iOS release artifacts.
- `.gitlab-ci.yml` adds self-hosted JavaScript/WebAssembly web verification and optional native artifact jobs; see `docs/GITLAB_CI.md`.
- Parts of `README.md`, inherited AI skills, and archived distribution workflows still show STRV/Firebase-era setup instructions. They are historical, not live release guidance; verify active settings against `pubspec.yaml` and `setup_app.dart`.

## Files To Treat Carefully
- Generated files: `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `lib/assets/*`
- Secrets and encryption tooling under `extras/secrets/`
- Environment files such as `.env`, `.env-development`, `.env-staging`, `.env-production`
- Release config such as `release_notes.txt`, native signing config, and CI-sensitive build files

## Known Template Gaps
- Google/Apple provider approval and Android/iOS/macOS/Windows/Linux OAuth callbacks need platform-specific confirmation.
- Windows/macOS/iOS GUI runtime, real physical-device verification, native release signing and store uploads are not proven by the seven compile-only jobs.
- Android API 34 emulator and Web Chromium passed one-off live **anonymous Auth** session lifecycle checks; these are not default recurring CI gates. Read `docs/SUPABASE_FIRST.md` for exact evidence.
- The optional Playwright PoC has no npm lockfile and is not a mandatory merge gate. Existing Patrol/Maestro scaffolding is retained without increasing broad UI E2E coverage.
- Legacy README, agent skills and old distribution instructions may describe the removed Firebase backend; don't restore them without a separate explicit decision.

## Best Documentation Strategy For Future AI Work
- Keep `AGENTS.md` short and actionable.
- Keep stable repo-map knowledge in this file.
- Keep coding conventions in `docs/PROJECT_GUIDELINES.md`.
- Avoid mixing template-wide facts with app-specific product rules unless those rules are visible in code.

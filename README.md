# Flutter Template

Cross-platform Flutter application template adapted from STRV. **GitHub `main` is the canonical public source and CI entrypoint.** The current default backend integration is **Supabase Auth**. This is a starter project, not a production-ready app.

## Current capabilities

- **Platforms:** Android, iOS, Web (JavaScript and WebAssembly), Windows, Linux and macOS. Hosted CI checks compilation across these platforms, **not** production distribution or interactive GUI readiness.
- **Architecture:** Flutter, Riverpod, AutoRoute, Freezed/code generation, Material 3, theme/localization, shared UI components and example routes.
- **Authentication:** Supabase anonymous Auth and session handling when a URL and publishable key are configured. Without both, the first-screen **Mock Sign In** is a UI-only demo.
- **Not included:** application database schema, migrations or CRUD; Firebase Auth/Messaging/Crashlytics/Analytics/Remote Config as active SDKs; production signing; store deployment; verified Google/Apple OAuth on physical devices.
- **Examples:** Home, Events, Profile, Debug Tools and authentication screens. No preconfigured notification, analytics, mobile threat-detection or proprietary REST API service.

## Quick start

Use the Flutter SDK pinned in `.fvmrc` (FVM recommended):

```sh
fvm flutter pub get
make gen
fvm flutter run -t lib/main_develop.dart
```

Flutter tooling requires local ignored `.env` and flavor-specific `.env-*` assets. Configure your own environment according to [Supabase Auth setup](docs/SUPABASE_FIRST.md); never commit secrets or personal project credentials. The CI-only `tool/create_ci_env.dart` generates non-secret placeholders for isolated compile checks, **not** production settings.

Useful commands:

```sh
make gen
fvm flutter analyze
fvm flutter test
```

For icons, splash screens and application renaming, use [Project setup](docs/PROJECT_SETUP.md). `make install` now only installs the pinned SDK and resolves dependencies.

The app exposes example Home, Events, Profile and Debug Tools screens. Production signing, store distribution, analytics, notifications and custom REST APIs are intentionally **not bundled**; integrate them only when an application actually requires them.

## Documentation

| Guide | Purpose |
| --- | --- |
| [AGENTS.md](AGENTS.md) | AI agent working rules and documentation ownership |
| [Project overview](docs/PROJECT_OVERVIEW.md) | Repository map, startup and feature inventory |
| [Project guidelines](docs/PROJECT_GUIDELINES.md) | Implementation conventions and test practices |
| [Project setup](docs/PROJECT_SETUP.md) | App icons, splash, rebranding and signing setup |
| [CI and publication](docs/CI.md) | GitHub-hosted builds, conditional runtime QA and public/private boundaries |
| [Runtime QA](docs/QA.md) | Web and Android optional smoke checks, live-test boundaries |
| [Supabase-first setup](docs/SUPABASE_FIRST.md) | Public configuration, Auth sessions, OAuth boundaries and one-time evidence |

Documentation belongs under `docs/` except these two root entrypoints (`README.md` and `AGENTS.md`). Tool-required files such as `.agents/skills/**/SKILL.md` are exceptions. Prefer revising the existing canonical guide over adding a separate README near a feature.

## Release and security boundaries

- **GitHub `main` is canonical.** Submit changes through GitHub branches and pull requests. Never copy personal NAS, workstation or private CI details into the public repository.
- Public CI is secret-free. Hosted Android AAB/iOS compilation artifacts are **not** signed store releases. See [CI](docs/CI.md).
- Inherited Firebase-era app distribution and Play Store pipelines are **not shipped** in the active public CI. Do not re-enable these SDKs or release jobs without a separate decision. See [Supabase-first setup](docs/SUPABASE_FIRST.md).
- Real anonymous Auth smoke tests may create users; they require explicit opt-in and a disposable test project. See [QA](docs/QA.md).

## Origins

This project derives from [STRV Flutter Template](https://github.com/strvcom/flutter-template). Preserve the original license and contributor attribution in [LICENSE](LICENSE). Unused STRV runtime and distribution scaffolding has been removed; this attribution and the existing LICENSE remain.

## Downloadable CI builds

The [Platform Builds Actions workflow](https://github.com/Uwaang/flutter-template/actions/workflows/platform-builds.yml) uploads build results after quality checks. Each run includes an **Artifact download guide** summary. For manual checks, use `compile-only-android` (profile APK plus AAB), `compile-only-windows` (extract the full ZIP, including the runtime files) or the appropriate Linux/Web/macOS/iOS bundle. Artifacts expire after **7 days** and are built with non-secret placeholder configuration: they are **not** production-signed, installer packages, full runtime QA, or Google/Apple OAuth builds. The macOS and iOS bundles are unsigned. See [CI](docs/CI.md).

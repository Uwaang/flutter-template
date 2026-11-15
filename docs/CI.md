# Continuous Integration and QA

The **public GitHub `main` branch is the canonical source** for this reusable Flutter template. Proposed changes use GitHub branches and pull requests. This repository does not automatically sync with a second source repository.

Any private historical CI or workstation-specific automation is managed separately and must **not** be copied into public branches, GitHub Actions, pull requests, logs, artifacts, or documentation.

## Default GitHub validation

Workflow: `.github/workflows/platform-builds.yml`

- On pull requests and pushes to `main`, run formatting, fixture unit tests, generated-source consistency, analyzer checks and Flutter tests.
- After the quality job succeeds, build **seven compile targets**: Web JavaScript, WebAssembly, Linux, Windows, Android profile AAB, macOS and unsigned iOS device app.
- Upload build artifacts for seven days using GitHub-hosted runners. The Windows ZIP includes runtime files but excludes intermediate debug/build outputs.
- Use only generated **non-secret placeholders** via `tool/create_ci_env.dart` and `tool/prepare_native_ci.py`; Android profile AAB uses synthetic/debug signing. These are **not** store-signed artifacts.
- A change consisting entirely of Markdown, agent guidance or archived workflow images is excluded using `paths-ignore`. Other changes still get the full quality and build matrix.
- `workflow_dispatch` remains available for an authorized manual build. Branch-protection required checks should be reviewed before marking an entire skipped workflow as required.

The active Flutter SDK version comes from `.fvmrc`. Executable workflow YAML and project configuration take precedence over historical text.

## Web runtime verification (conditional)

Workflow: `.github/workflows/web-runtime-smoke.yml`

- Run automatically on relevant PRs and `main` pushes affecting `lib/`, `assets/`, `web/`, `qa/web/`, web runtime workflow, Flutter/lock/config versions or CI fixture setup.
- Compile **both Web JS and Web WASM**, then run the same Playwright Chromium first-screen smoke against each compiled artifact.
- The SPA server in `qa/web/spa_server.py` provides route fallback for refreshed client-side URLs without silently hiding missing assets.
- This is separate from compiling successfully. It checks that the splash disappears and the mock login actually renders.
- The tests do not use real Supabase credentials by default. See [QA](QA.md) for details.

The independent runtime job currently recompiles Web JS/WASM instead of consuming the platform build job's archives. Do not add an artifact handoff just to save lines; consider it only after comparing runtime, complexity and failure isolation.

## Android runtime verification (manual)

Workflow: `.github/workflows/android-runtime-smoke.yml`

- **Manual `workflow_dispatch` only**. An Android emulator run is not a required PR or `main` merge gate.
- Build a non-production profile APK, start an Android API 34 emulator, assert the rendered `Mock Sign In` screen and retain useful failure evidence.
- The Gradle preparation experiment uses `gradle/actions/setup-gradle@v6` with `cache-provider: basic` (open-source cache), replacing bespoke multi-mirror download and ZIP caching. The wrapper distribution remains version 8.14.3 and pins `distributionSha256Sum` in `android/gradle/wrapper/gradle-wrapper.properties`.
- `setup-gradle` validates the wrapper JAR. The distribution SHA check is enforced separately by Gradle Wrapper.
- **The simplified Gradle path is experimental until the emulator job succeeds**; restore the prior implementation if the old failure mode reappears. No auto-trigger is left on long-lived branches.

GitHub's `workflow_dispatch` is available for workflow files published on the repository default branch. Before this branch is merged, validate the experiment in an explicitly approved isolated test run rather than claiming it has passed.

## Real Supabase authentication

SDK, browser and Android live-auth tests remain **opt-in only** and must use a disposable test project. These tests can create real anonymous users, so they must never run automatically on public pull requests or against a production backend. See [Supabase-first setup](SUPABASE_FIRST.md) and [QA](QA.md).

## Public-source security and releases

- Keep standard CI on **GitHub-hosted runners** with read-only contents permissions. Do not register private lab computers, self-hosted runners or private network access as runners for untrusted public PRs.
- Do not add private CI YAML, internal DNS/IP addresses, personal directories, credentials, protected variables or signed release keys to public source or build logs.
- Inherited Firebase app-distribution and Play Store workflow examples are not part of the active repository CI. Do not reinstate them without a separate release design and review.
- Host compilation is **not** GUI-runtime validation on Windows/macOS/iOS, production code signing, full OAuth verification or App Store/Play Store deployment.
- The original upstream STRV license and attribution remain in source control.

See [Project setup](PROJECT_SETUP.md) for local configuration and private signing guidance, and [Project overview](PROJECT_OVERVIEW.md) for the app's actual startup integrations.

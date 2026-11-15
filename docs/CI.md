# Continuous Integration and Publication

This is the single reference for **GitLab canonical CI** and the **GitHub public build mirror**. For runtime QA, see [QA.md](QA.md); for backend setup, see [SUPABASE_FIRST.md](SUPABASE_FIRST.md). The workflow files are the executable source of truth when documentation and CI differ.

## GitLab source and GitHub mirror

## Ownership and Publication

GitLab is the source of truth. GitHub is a public build/review mirror, not an
independent production deployment. Only the reviewed publication branch is
mirrored; never use `git push --mirror` or `--all`. Do not publish private lab
branches, VM provisioning, local logs, or old workstation artifacts.

The current reviewed baseline is shared by GitLab `master` and GitHub `main` (commit `a58471db` as of 2026-11-10). New changes must be reviewed on a branch, integrated to the canonical GitLab repository, and then published to GitHub as the same commit. This document does not authorize any push or merge. New public commits use a GitHub noreply identity. Existing public-template and
local contributor history retains its original authorship metadata.

After explicit integration approval, compare both remotes and verify that GitHub `main` receives the same reviewed GitLab commit. Configure `origin` privately for the source repository and `github` as `git@github.com:Uwaang/flutter-template.git`; do not embed authentication in URLs.
There is no scheduled or token-bearing mirror service. Changes made through
GitHub PRs must be reviewed and imported into GitLab before becoming the next
canonical publication; do not independently advance the two mainlines.

## Inherited Encryption Samples

Upstream STRV history includes an age private key together with encrypted sample
environment/signing files. Their contents match the already-public upstream.
The private-key file is removed from the current tree, but remains in public
upstream history. Treat all inherited encrypted fixtures as PUBLIC EXAMPLES,
not as protected secrets. Never reuse that key, example signing material, or
configuration for production. Create fresh keys and private configuration for a
real application. The original MIT license and notices are retained.

The compile workflow does not decrypt any fixture, access any production backend,
upload Crashlytics symbols, sign an App Store release, or deploy to a store.
Secret-backed upstream workflows have `.disabled` extensions and are not active.
Their historical deployment setup advice is not a required permission policy
for this mirror.

## Hosted Build Checks

`Platform Builds` runs on pushes, PRs, or manual dispatch with read-only repository
permissions and no user-provided secrets. Flutter is pinned by `.fvmrc`. Quality,
formatting, analysis, unit/widget tests, and fixture tests precede the builds.

| Target | Hosted OS | Evidence |
| --- | --- | --- |
| Web JS / WASM | Ubuntu | Separate compiled web archives |
| Linux | Ubuntu | Release runtime bundle |
| Windows | Windows | Release runtime ZIP, without intermediate libraries/symbols |
| Android | Ubuntu | Profile AAB using debug signing and non-production CI fixtures |
| macOS | macOS | Release application bundle |
| iOS | macOS | Unsigned device compilation, not an installable store IPA |

Every matrix job has a 45-minute timeout; failures do not cancel unrelated targets.
Artifacts expire after seven days. These checks prove compilation only, not
authentication, device behavior, RASP integration, signing, or store readiness.
Android profile resources use production's launcher assets, while signing remains
debug-only. The iOS compile-only environment explicitly skips symbol upload;
normal project release behavior is unchanged when that flag is absent.

Use runner checkout paths and relative artifact paths. Build tools can embed their
own hosted build paths in binaries; this is distinct from leaking a personal PC
home directory. Re-scan source history and generated bundles before publication.
Do not modify executable/DLL bytes merely to remove embedded path strings.

## Web ChatGPT Handoff

A connected GitHub tool can inspect public code, commits, PRs and Actions results
subject to its actual exposed tools. Write/dispatch permissions must be verified
in that chat; public visibility alone does not grant them. Contributors should
use a branch and PR, keep this workflow secret-free, and return changes to the
GitLab source rather than establishing an unrelated second mainline.

## Self-hosted GitLab verification

This repository retains selected STRV workflow history and adds a separate GitLab CI path for self-hosted use. The active Flutter backend is Supabase Auth; inherited secret-backed deployment workflows remain disabled.

## Goals

- Keep Flutter pinned to the same SDK as `.fvmrc`.
- Validate both JavaScript and WebAssembly web builds.
- Preserve the Riverpod/use-case layout and freeRASP while keeping current Supabase-first Auth distinct from the inherited STRV/Firebase release examples.
- Keep secret-backed release jobs separate from ordinary analysis/test/build validation.
- Make native desktop/mobile runners optional: missing Windows or macOS runners must not block ordinary Linux/Web verification.

## Automatic verification

The default GitLab path runs on a Linux Docker runner:

1. `flutter pub get`
2. create ignored, non-secret `.env*` placeholder files with `tool/create_ci_env.dart`
3. formatting check
4. localization/code generation
5. generated-diff check
6. `flutter analyze`
7. `flutter test`
8. JavaScript web release build
9. WebAssembly web release build

The two web builds are intentionally separate. A dependency can support the normal JavaScript backend while still importing a legacy web library that prevents `dart2wasm` compilation.

## WebAssembly policy

Prefer packages that support Dart's modern web interop:

- `package:web` instead of `dart:html`/legacy HTML wrappers
- `dart:js_interop` instead of `dart:js` or `package:js`

The template's own web setup uses `package:web`. New dependencies should keep the `web_wasm` job green whenever practical.

WASM readiness is a compatibility target, not a requirement to deploy only WASM. Keep the normal JavaScript web build because browser/platform support and third-party integrations can differ.

## Native build jobs

Native artifacts are manual by default so a NAS-only Linux runner can still provide useful CI.

- `linux_release`: Linux runner/container; produces a tar.gz bundle.
- `android_release`: a **manual legacy packaging job**; the existing script still checks for a Firebase-era Android config and release signing files. This does not mean Firebase Auth is enabled. Review and modernize the release recipe separately before running it against the Supabase-first template.
- `windows_release`: Windows shell runner tagged `windows` and `flutter`.
- `ios_release`: macOS shell runner tagged `macos` and `flutter`; signing/export remains project-specific.

When dedicated runners become permanently available, individual jobs can be changed from manual to automatic without changing application architecture.

## Placeholder environment files

`tool/create_ci_env.dart` writes only ignored, non-secret placeholder values. They exist so code generation, analysis, tests, and compile-only web/desktop checks do not depend on production secrets.

Do not use those values for distribution builds. Android/iOS release jobs should restore the project's real encrypted configuration/signing material through protected GitLab CI variables or another approved secret mechanism.

## CI image note

The initial Linux jobs use `ghcr.io/cirruslabs/flutter:3.44.0` because it exactly matches the upstream STRV Flutter pin. Cirrus Labs stopped publishing new Flutter images in 2026, so a future Flutter upgrade should also replace this image source or move to a small internally maintained CI image based on the official Flutter SDK archive.

# GitLab CI for the multi-platform template

This repository retains selected STRV workflow history and adds a separate GitLab CI path for self-hosted use. In the SCRUM-437 branch the active Flutter backend is Supabase Auth; secret-backed inherited deployment workflows remain disabled.

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

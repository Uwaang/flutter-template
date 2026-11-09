# Android runtime smoke (SCRUM-435)

One **optional** GitHub Actions run: build a synthetic, debug-signed Android
profile APK, launch it in an API 34 emulator, and assert the visible
\`Mock Sign In\` screen. This is **not** a required merge/release gate.

- Workflow: \`.github/workflows/android-runtime-smoke.yml\`; QA-branch changes
  to smoke test files start it. Manual dispatch is possible after the workflow
  is available on the repository's default branch.
- Fixture: \`qa/mobile/prepare_ci_env.py\` derives SHA-256 signing hash from
  the existing debug keystore and corrects the app ID in generated,
  gitignored \`.env*\` files. No Firebase or OAuth credentials are supplied.
- Test: \`qa/mobile/run_once.sh\` checks actual Android UI hierarchy and
  keeps screenshot/logcat evidence.
- Gradle 8.14.3 archive: verified by pinned official SHA-256 before use.

The optional \`qa/mobile/startup.yaml\` Maestro example and existing Patrol
tests remain unchanged. No login success, real backend, release signing, iOS
or desktop runtime is verified.

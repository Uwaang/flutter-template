# Public CI and Mirror Policy

## Ownership and Publication

GitLab is the source of truth. GitHub is a public build/review mirror, not an
independent production deployment. Only the reviewed publication branch is
mirrored; never use `git push --mirror` or `--all`. Do not publish private lab
branches, VM provisioning, local logs, or old workstation artifacts.

The initial publication source is GitLab branch `scrum-430-public-ci`, mirrored
to GitHub `Uwaang/flutter-template` branch `main`. The same Git commit must exist
on both sides. A merge into GitLab `master` remains a separately reviewed event.
New public commits use a GitHub noreply identity. Existing public-template and
local contributor history retains its original authorship metadata.

For an approved clean checkout on the publication branch, after fetching and
reviewing both remotes:

```sh
git push origin HEAD:refs/heads/scrum-430-public-ci
git push github HEAD:refs/heads/main
```

Configure `origin` privately for the source repository and `github` as
`git@github.com:Uwaang/flutter-template.git`. Do not embed authentication in URLs.
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

The compile workflow does not decrypt any fixture, access production Firebase,
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
| Android | Ubuntu | Profile AAB using debug signing and synthetic Firebase config |
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

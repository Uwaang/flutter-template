# SCRUM-437 — Supabase-first Flutter template

**Scope:** Supabase Auth/session becomes the backend entrypoint. This migration
is separate from the already-green hosted build and runtime smoke PRs.

## Verified QA and remaining boundaries (2026-11-10 KST)

- Real anonymous Supabase Auth client sign-in, refresh-token session restoration,
  and local sign-out passed an opt-in Flutter SDK test:
  [SDK run](https://github.com/Uwaang/flutter-template/actions/runs/42776324792).
- A compiled Flutter Web browser session passed real anonymous login, full
  reload with session restored, sign-out, signed-out reload, and protected
  route checks: [one-time Web E2E](https://github.com/Uwaang/flutter-template/actions/runs/42784400895).
- An Android API 34 emulator passed real anonymous login, **app process
  relaunch** with session restored, logout, and signed-out relaunch:
  [one-time Android E2E](https://github.com/Uwaang/flutter-template/actions/runs/42785429226).
- Hosted quality plus all seven **compile-only** targets passed:
  [platform matrix](https://github.com/Uwaang/flutter-template/actions/runs/42788052694).
  Web JS and Web WASM compiled first-screen checks passed:
  [Web runtime smoke](https://github.com/Uwaang/flutter-template/actions/runs/42788045284).
- The temporary push-triggered live Web and Android test **workflows were
  removed after success**. Optional test scripts remain for explicitly
  authorized runs using a disposable project. Running them can create new
  `auth.users` records; signing out does not delete those records.
- **Not verified:** Google/Apple provider OAuth, physical Galaxy/other device,
  native OAuth callbacks, Windows/macOS/iOS interactive GUI behavior,
  production signing or app-store distribution.

## Scope and stop condition

A. SDK, public configuration and session initialization.
B. Replace anonymous/Google/Apple login, logout and token use cases. Preserve
   the existing Riverpod/use-case pattern. OAuth completion must follow the
   auth-state event, not mere browser launch.
C. Remove unused Firebase Auth/Crashlytics/Analytics/Remote Config/Messaging
   from the default template. Push, analytics and crash reporting remain
   optional future integrations, **not replacement features in this task**.
D. Reuse the existing Android/Web JS/Web WASM first-screen smoke tests and
   seven-platform compile CI; record unverified live provider flows.

**Explicitly excluded:** creating or modifying database tables, SQL schema,
migrations, CRUD APIs, Supabase Storage, user profile tables, Edge Functions,
hosting Supabase, real user migration, and service-role keys. No database
SELECT/INSERT/UPDATE/DELETE is added under this task. If needed, make a
separate SCRUM.

## Environment

Supply these in the local gitignored `.env` and flavor-specific `.env-*`
files before testing actual authentication:

- `SUPABASE_URL` — the HTTPS project URL.
- `SUPABASE_PUBLISHABLE_KEY` — the **public** publishable key, never the
  service-role or secret API key.
- `SUPABASE_OAUTH_REDIRECT_URL` — application deep-link callback for native
  OAuth; register exactly the same callback in the Supabase Auth allow list.

If both URL and key are absent, first-screen CI uses an **unconfigured / mock
UI-only** startup. This does not test a real Supabase connection or auth.
Providing exactly one of the URL/key pair is a configuration error.

## Live authentication and security

- Enable the required Auth providers in the Supabase Dashboard. Anonymous
  login creates a *real user*; it is not the same as the public anon API key.
- Google/Apple OAuth depends on external provider consent and redirect
  configuration per platform. This work does not assume those credentials.
- Native OAuth callbacks require registered Android intent filters and
  Apple URL schemes. Do not claim OAuth E2E green solely from a build.
- If a future project creates tables, enable and review RLS before exposing
  any Data API resources. **No database resources are added here.**

## Repository and change policy

GitHub `main` is the canonical public source; send subsequent Auth changes through
reviewed GitHub branches and pull requests. The earlier SCRUM-437 implementation
branches and draft PR references are historical evidence, not an active merge
sequence. Do not enable real Auth in public CI or add Supabase database/CRUD
without a separate explicit decision.

## Native OAuth callback template

For Android, iOS and macOS, the template registers the URI scheme
`fluttertemplate` with host `login-callback`. Configure
`SUPABASE_OAUTH_REDIRECT_URL=fluttertemplate://login-callback` in real
local flavor environment files and add that exact URL to your Supabase Auth
redirect allow list. A real Supabase project plus Google/Apple provider
credentials are required for functional OAuth E2E validation.

Windows/Linux may require platform-specific protocol handler registration.
These desktop OAuth callbacks have **not** been proven end-to-end. Keep the
same UseCase API, but do not claim authenticated desktop runtime support yet.

Supabase Auth anonymous users are *authenticated* principals. If later
introducing database tables, RLS must distinguish `is_anonymous`, but
**this task creates no database tables or CRUD methods**.

## One-off live Auth smoke (disposable test project only)

The CI quality/Android/Web checks intentionally do **not** create Supabase
users. A single live Auth check is available but is **opt-in only** and is not
an automated release gate. Use a dedicated, disposable Supabase **test project**
with **Auth → Anonymous Sign-ins enabled**. Never use a production project.

The local test only exercises **Supabase Auth**: one anonymous sign-in, the
resulting authenticated session, restoring that session via a refresh token in
a second client, and local sign-out. It performs **no application-table CRUD,
SQL, profile writes, Storage, or Edge Functions**. An anonymous Auth user is
still created in the Supabase project; **sign-out does not delete this user**.
Manual removal from the Auth Users dashboard may be needed after testing.

PowerShell, from the repository root (using the existing Flutter toolchain):

```powershell
$env:RUN_SUPABASE_AUTH_SMOKE = '1'
$env:SUPABASE_URL = 'https://YOUR-TEST-PROJECT.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY = 'YOUR_PUBLIC_PUBLISHABLE_KEY'
flutter test test/live_supabase_auth_smoke_test.dart
Remove-Item Env:\RUN_SUPABASE_AUTH_SMOKE, Env:\SUPABASE_URL, Env:\SUPABASE_PUBLISHABLE_KEY
```

The public publishable key is expected. **Do not use an API secret,
service-role key, JWT signing secret, database password or personal account**.
The test is automatically skipped if `RUN_SUPABASE_AUTH_SMOKE` is absent; the
usual CI test run never performs a live sign-in.

### App session persistence — manual real-device or browser check

1. In the test project's dashboard, enable **Anonymous Sign-ins**. Copy the
   test project URL and *publishable* key into the local, gitignored `.env`
   and the flavor-specific `.env-production` used by the app (keep existing
   non-Supabase configuration in those files). Do **not** commit either file.
2. Run the Flutter app locally with the production entrypoint and chosen
   target, e.g. `flutter run -d chrome -t lib/main_production.dart`.
3. Confirm that `Mock Sign In` is **absent** while the test backend is
   configured. Select **Sign in Anonymously**; confirm that authentication
   succeeds and the root/profile page appears.
4. Close and reopen the app or reload the browser page, without clearing
   its storage. Confirm the same session is restored and the user remains
   signed in. A refresh-token API test alone does **not** prove this.
5. Use **Sign out** in the profile page; confirm the authentication screen
   reappears and remains signed out after reload.

Google/Apple OAuth require separate provider configuration, registered
callback URLs and platform-specific tests. Browser launch alone is **not**
a successful OAuth sign-in. Never claim these are verified from this smoke.

## SCRUM-448 — Google/Apple OAuth integration checklist (2026-11-17)

The Google and Apple buttons already call Supabase Auth's `signInWithOAuth`.
They **do not** use direct Google/Apple SDK packages or create profile tables.
The existing Auth-state stream and session restoration determine success,
**not** whether the browser opened.

### Callback URLs (three distinct locations)

1. **Google Cloud / Apple Developer provider callback** — use the Supabase
   project's provider callback URL from the Authentication > Providers screen,
   normally `https://<project-ref>.supabase.co/auth/v1/callback`. This is
   **not** the GitHub Pages URL or native app deep link.
2. **Supabase Authentication > URL Configuration > Redirect URLs** — add the
   *actual Flutter app return URLs* to this allow list. Keep these exact for
   release/staging; examples:
   - `https://uwaang.github.io/flutter-template/` (main Pages root)
   - `https://uwaang.github.io/flutter-template/previews/pr-N/`
     (specific preview only, if running a separately authorized real-Auth
     preview; avoid granting all preview paths)
   - `http://localhost:8080/authentication` (only for a local Web path-route
     test on that port and route)
   - `fluttertemplate://login-callback` (registered Android/iOS/macOS scheme)
3. **Flutter app `redirectTo`** — the use cases choose the current Web HTTP(S)
   origin + **pathname**, stripping any query and Flutter hash fragment, or
   `SUPABASE_OAUTH_REDIRECT_URL` on native. This preserves Pages' nested
   `/flutter-template/previews/pr-N/` base path, rather than falling back
   unintentionally to a Supabase Site URL for all apps.

On Pages, Flutter uses hash routing, e.g.
`https://uwaang.github.io/flutter-template/#/authentication`. Only the
existing document path `https://uwaang.github.io/flutter-template/` belongs
in the redirect allow list; `#/authentication` is a client-side fragment,
not a route that GitHub Pages serves. Local SPA hosts may use path routing
and need an `index.html` rewrite for direct-route refreshes.

### Provider configuration (outside the public repository)

- **Google:** Set up the Google Auth Platform consent screen / audience and
  a **Web application** OAuth Client ID. In Authorized redirect URIs use
  Supabase's `/auth/v1/callback`; set the allowed origin as required for
  the app. Restrict testing to approved test users. Copy the client ID and
  secret into **Supabase Auth > Sign In / Providers > Google**.
- **Apple:** An Apple Developer Program account with Sign in with Apple
  capability, primary App ID, web Services ID, permitted domain/return URL,
  Team ID, Key ID and an Apple private key are required. Use the Supabase
  provider callback as the Apple return URL and configure the Apple
  provider **inside Supabase**, not in Flutter. Web OAuth does not reliably
  supply an Apple full name; the app already falls back when absent.
- **Never** place Google/Apple client secrets, Apple private keys, Supabase
  `service_role` keys, or unredacted authentication tokens into GitHub,
  public CI, committed `.env*`, screenshots or logs. Only public Supabase
  publishable keys are allowed in the Flutter client.

### Verification stages and boundaries

1. Keep public Pages publishing **mock-only** by default; its current
   `tool/create_ci_env.dart` fixtures intentionally leave Supabase
   unconfigured, so public Pages does not exercise OAuth.
2. For real tests use an **explicitly approved disposable Supabase QA project**
   and local ignored flavor `.env*` files. Register a stable local-origin
   return URL in Supabase, then test Google first: provider consent, return
   to the correct app, real non-expired session, reload/session restore,
   sign-out, and signed-out reload. Repeat separately for Apple once its
   provider credentials exist.
3. For Android/iOS/macOS verify the registered URI handler returns to
   the running app and restores the session, not merely that a browser
   launches. `fluttertemplate://login-callback` is a starter scheme that
   must be changed when rebranding or if another installed app could
   claim it. Windows/Linux protocol handler registration and interactive
   OAuth are not verified.
4. After each real test, review any user records created in `auth.users`
   on the disposable project. Sign-out does **not** delete them. Avoid
   enabling unlimited public signup or publishing QA credentials without
   a separate explicit decision.

The regular GitHub Flutter quality, seven-platform compile-only and Web
JS/WASM mock runtime checks **cannot prove Google or Apple OAuth E2E**.
Provider secrets and account approvals are external prerequisites. No
schema/database/CRUD/Storage work is part of SCRUM-448.

References:
- https://supabase.com/docs/reference/dart/auth-signinwithoauth
- https://supabase.com/docs/guides/auth/redirect-urls
- https://supabase.com/docs/guides/auth/social-sign-in/auth-google
- https://supabase.com/docs/guides/auth/social-sign-in/auth-apple
- https://supabase.com/docs/guides/auth/native-mobile-deep-linking

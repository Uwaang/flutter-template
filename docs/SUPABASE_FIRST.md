# SCRUM-437 — Supabase-first Flutter template

**Scope:** Supabase Auth/session becomes the backend entrypoint. This migration
is separate from the already-green hosted build and runtime smoke PRs.

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

## Branch policy

Baseline: GitHub Draft PR #1 and Draft PR #2. Work on isolated
`feat/scrum-437-supabase-first` branched from PR #2, then review GitLab
canonical synchronization and merge order separately. Do not merge without
the SCRUM-437 acceptance checklist.

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

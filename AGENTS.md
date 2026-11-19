# AI Agent Guide

Use this file as the entrypoint for automated work in this repository.

## Read Order
1. `docs/PROJECT_OVERVIEW.md` for the repo map, startup flow, and feature inventory.
2. `docs/PROJECT_GUIDELINES.md` for implementation conventions and workflow defaults.
3. `README.md` for the current quick start and links to detailed guides.

## Repo Summary
- This is a Flutter template, not a fully productized app.
- Core stack: `flutter_riverpod`, `riverpod_annotation`, `freezed`, `json_serializable`, `auto_route`, Material 3, Supabase Auth (`supabase_flutter`), and FVM-managed Flutter.
- The app includes example features, navigation, theming, codegen, and localization; unused REST, analytics, notification, RASP, and release scaffolding was removed.
- Some integrations are intentionally scaffolded but not fully enabled yet. Check `lib/app/setup/setup_app.dart` before assuming a service is active.

## Working Defaults
- Keep new screen work inside `lib/features/<feature>/`.
- Prefer the existing file pattern when a feature has state:
  - `*_page.dart`
  - `*_page_content.dart`
  - `*_state.dart`
  - `*_event.dart`
- Keep page widgets thin. Put heavier UI in `*_page_content.dart`.
- Prefer shared widgets and extensions from `lib/common/` before introducing new app-specific primitives.
- Introduce DTOs and a network client only when a concrete backend feature needs them; the base app has no generic REST API client.
- Use Riverpod providers and use cases instead of wiring IO directly in widgets.

## Repository and CI Ownership
- GitHub `main` is the canonical source for this public template. Use GitHub branches and PRs; do not assume a private GitLab mirror must be updated.
- `.github/workflows/platform-builds.yml` is the hosted quality and seven-platform compile workflow. Web runtime smoke is conditional on relevant changes; Android emulator startup is manual only.
- Keep private lab or workstation CI, local runner settings, internal URLs, signing keys and credentials out of public branches, workflow logs and artifacts.
- Do not reintroduce inherited Firebase distribution workflows just because old agent skill instructions mention them.
- Do not run live Supabase Auth tests without explicit opt-in and a disposable test backend.

## Codegen And Commands
- Run `make gen` after changing `@riverpod`, `@freezed`, `@RoutePage`, localization, or generated asset inputs.
- Use `make watch` for continuous code generation when doing annotation-heavy work. This is a human-only command — agents must never run it (it spawns a persistent background watcher). Agents always use one-shot `make gen`.
- Do not hand-edit generated files such as `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, or files under `lib/assets/`.
- Preferred validation commands:
  - `fvm flutter analyze`
  - `fvm flutter test`
  - `make gen`

## Safety Notes
- Keep secrets in an external private store. Local `.env*` files are gitignored; CI-only environment fixtures contain no credentials. Never add secrets to commits, PRs, logs, or public artifacts.
- Supabase Auth initializes only with a public project URL/key pair; without it, the first-screen mock is UI-only. Firebase Auth, Messaging, Analytics, Crashlytics and Remote Config are not active SDK integrations; local notification and freeRASP services are not bundled.
- CI builds compile-only unsigned/synthetic platform artifacts. Production signing, releases and store distribution require separate private setup and explicit authorization.

## Documentation Ownership (mandatory)
- **Canonical human-readable documentation belongs in `docs/`.** The only documentation entrypoints at the repository root are `README.md` (overview and quick start) and `AGENTS.md` (agent instructions).
- Before creating a document, check whether an existing `docs/` page covers the subject. **Update the existing page first.** Avoid scattered `README.md`, `NOTES.md`, implementation reports, and redundant summaries alongside feature/test code.
- Maintain one source of truth per topic: `docs/PROJECT_OVERVIEW.md` for the repo map, `docs/PROJECT_GUIDELINES.md` for implementation rules, `docs/CI.md` for GitHub Actions CI and public-source boundaries, `docs/QA.md` for runtime smoke checks, `docs/SUPABASE_FIRST.md` for Auth setup, and `docs/PROJECT_SETUP.md` for app initialization and Android signing. Other documents should link to these instead of copying their content.
- When changing behavior, dependencies, CI, commands, or public setup, check whether the canonical documentation becomes inaccurate; update affected content **in the same change**. A code-only change that does not affect any documented contract needs no documentation edit.
- For document moves/renames, update inbound links and delete superseded files. Do not preserve obsolete duplicated guidance merely as a stub.
- Tool-required artifacts (for example `.claude/CLAUDE.md`, `.agents/skills/**/SKILL.md`, command definitions, code templates and configuration files) may remain at required paths. These are not permission to create independent narrative documentation elsewhere.
- Prefer the smallest useful documentation change; do not introduce a separate docs framework or a mandatory documentation update for each trivial fix.

## Reusable Workflows
Repeatable procedures live as skills under `.agents/skills/<name>/SKILL.md` —
the cross-client location defined by the [Agent Skills](https://agentskills.io)
format. Each skill has YAML frontmatter (`name:`, `description:`) so it can be
auto-discovered by AI tools that support skills.

Some inherited skills still describe the former Firebase-based STRV template.
Treat those passages as historical until updated;
`pubspec.yaml`, `setup_app.dart`, and `docs/SUPABASE_FIRST.md` define the
current service boundaries. Do not add a database or CRUD for SCRUM-437.

Existing skills:
- `project-setup` — customize app identity, icons and splash; disregard inherited Firebase/secret provisioning
- `feature-screen` — add a new route / screen using the existing feature pattern
- `feature-data-flow` — build a full backend-backed feature (DTOs, entities, use cases, state, UI)
- `upgrade` — upgrade Flutter SDK and package dependencies
- `release-prepare` — version bump, release notes, release branch, release PR
- `release-builds` — historical guidance only; no active signed release pipeline
- `secrets-bootstrap` — historical guidance only; deleted SOPS fixtures must not be restored by default
- `pr-review` — bug-first review of branches / diffs / PRs
- `review-pr-comments` — triage and resolve AI or human GitHub PR feedback
- `create-pr` — verify, commit, push, and create or update a GitHub PR
- `lint-format` — run Flutter/Dart formatting and analyzer checks
- `widget-test` — add or update focused widget tests using this template's Riverpod, localization, theme, and route patterns
- `layout-debug` — diagnose and fix Flutter overflow, constraints, scroll, and responsive layout issues
- `build-verify` — full build/test/analyze/format pass (codegen + analyze + test, then iOS + Android builds in parallel, then `dart format`); auto-scopes to the diff and leaves the working tree dirty for review
- `start-job` — run the post-spec implementation pipeline (`tasks` → `implement-tasks-sequence` → `build-verify` → `pr-review`)
- `prd` — create a Flutter feature Product Requirements Document under `.claude/tasks/<feature>/prd.md`
- `tasks` — break a PRD + tech spec into discrete, dependency-ordered Flutter implementation tasks under `.claude/tasks/<feature>/` using `.agents/templates/task.md` and `.agents/templates/task-list.md`
- `implement` — implement one generated Flutter task using the repo architecture and verification rules
- `implement-tasks-sequence` — execute generated task files in dependency order before final verification
- `techspec` — translate a PRD into an implementation-ready Flutter tech spec at `.claude/tasks/<feature>/techspec.md`; verify current Supabase-first backend boundaries before following inherited Firebase examples
- `spec-feature` — run the full specification pipeline (`prd` → `techspec` → `tasks`) in one shot, from feature idea to implementation-ready tasks

### How AI tools find these skills
- **Spec-compliant agents** scan `.agents/skills/` directly — it is the
  standard cross-client skills location, so no extra wiring is needed.
- **Codex** reads this `AGENTS.md` and the referenced
  `.agents/skills/<name>/SKILL.md` files. When delegating, mention the workflow
  by name, e.g. *"use the feature-data-flow workflow"*.
- **Claude Code** auto-discovers skills through `.claude/skills/<name>` symlinks
  that point at `.agents/skills/<name>/`. Each skill is also exposed as a slash
  command at `.claude/commands/<name>.md`, so `/feature-screen`, `/pr-review`,
  `/release-prepare`, etc. work as explicit invocations.

### Creating a new skill
When adding a new repeatable workflow, complete all five steps so Codex, Claude,
and other skills-compliant agents can use it:
1. **Author the skill.** Create `.agents/skills/<name>/SKILL.md` with YAML
   frontmatter and the workflow body. Required fields:
   - `name:` matching the folder
   - `description:` explaining when to use the skill
   - `allowed-tools:` listing the tools the skill needs (for example
     `Bash Read Grep Glob Edit Write`; add `Agent` for skills that delegate
     to subagents, `Skill` for orchestrators that invoke other skills)
   - `model:` selecting the model — use `claude-sonnet-4-6` for most
     implementation, verification, and review workflows, and `claude-opus-4-7`
     for spec-writing skills like `prd` and `techspec`
   - `user-invocable: true` only on top-level entry-point skills such as
     `start-job` and `create-pr`
2. **Mention it for Codex.** Add the skill to the "Existing skills" list above.
3. **Expose it to Claude Code (auto-discovery).** Add a symlink:
   `ln -s ../../.agents/skills/<name> .claude/skills/<name>`
4. **Add a slash command.** Create `.claude/commands/<name>.md` using one of the
   existing commands as a template — a short frontmatter (`description`,
   `argument-hint`) and a one-line body that invokes the skill, followed by
   `$ARGUMENTS`.
5. **Validate.** Run `python3 .agents/validate_skills.py` and fix any reported
   issues. It checks Agent Skills spec compliance (strict YAML frontmatter,
   name/description rules) and that the Claude Code symlink and slash command
   from steps 3-4 exist. Also run it after editing any existing SKILL.md
   frontmatter.

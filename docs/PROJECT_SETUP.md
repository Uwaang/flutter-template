# Project Setup

Use `project_setup/` to customize a new application from this starter. This project is Supabase-first, not the original STRV Firebase distribution template.

## Identity, icons and splash
1. Update `project_setup/lib/configuration.dart` with the desired app name, package ID and visual settings. The starter's generic `com.example.fluttertemplate` is a placeholder, not a deployable production identity.
2. Save a transparent 900 × 900 PNG at `project_setup/resources/icon.png` to generate icons.
3. Save a transparent 768 × 768 PNG at `project_setup/resources/splash.png` for splash art, with the visible area inside a circle.
4. From the repository root, run `make setup` and choose the relevant option.

The tool owns the generated icon and splash files. After changing native identity or resources, run `make gen`, `make analyze` and the platform builds relevant to your app.

## Private signing and distribution
The starter's GitHub Actions use synthetic, compile-only configuration. They do **not** publish signed production artifacts or provide store credentials.

For an actual Android release, generate a private keystore using `keytool`, for example:

```sh
keytool -genkeypair -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 20000 -storetype PKCS12 -alias YOUR_PRIVATE_ALIAS
```

Enter a private password interactively. Never commit keystores, passwords, provisioning profiles, Google OAuth secrets, Apple private keys or any other signing material.

The inherited `extras/secrets` SOPS/age fixtures and Makefile decrypt/deploy commands have been removed. Store project-specific secrets in a separate private system and configure signing independently for each app. Do not treat compile-only AAB or unsigned iOS artifacts as store-ready releases.

## Documentation ownership
Keep this guide current when the setup tool or native build identity changes. Update `docs/CI.md` for build/QA gates and `docs/SUPABASE_FIRST.md` for authentication settings; do not reinstate historical Firebase/STRV provisioning by accident.

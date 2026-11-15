# Project Setup

Use the existing `project_setup/` Dart tool to customize a new app from this Flutter template. Run these steps from the **repository root**. The active backend is Supabase Auth, not the inherited STRV Firebase integration; see [Supabase-first setup](SUPABASE_FIRST.md).

## App identity, icon and splash screen

1. Edit `project_setup/lib/configuration.dart` to specify the app name, package ID and visual settings.
2. For icon generation, save a transparent **900 × 900 PNG** at `project_setup/resources/icon.png`.
3. For splash generation, save a transparent **768 × 768 PNG** at `project_setup/resources/splash.png`; the visible artwork must fit a circle.
4. From the repository root, run:

```sh
make setup
```

The make target runs `fvm dart pub get` inside `project_setup/` and opens the Dart setup menu. Choose icon generation, splash generation or application/package rebranding as required. The generators validate the input dimensions and report external tool failures.

Do not run `make install` just for icons or renaming: its current definition also installs extra tools, invokes secret decryption and activates inherited FlutterFire tooling. Review that target before using it on a new project.

After changing generated assets or app identity, run `make gen`, `fvm flutter analyze`, and the relevant platform checks. Do not edit generated assets or native files by hand if the setup tool owns them.

## Android signing and keystores

Android release signing requires **fresh, privately managed credentials**, not sample material inherited from STRV. The public repository is not a production keystore source.

If a new application needs an Android signing key, generate one with JDK `keytool` using a private alias and an interactive password prompt, for example:

```sh
keytool -genkeypair -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 20000 -storetype PKCS12 -alias YOUR_PRIVATE_ALIAS
```

Do not commit the generated keystore, passwords, or private key. For PKCS12, the keystore and key passwords may be required to match. To inspect a certificate without printing secrets, run `keytool -list -v -keystore PATH_TO_KEYSTORE` and provide the password interactively.

The inherited release configuration expects encrypted material under `extras/secrets/` and uses SOPS/age scripts. The current make targets include `make secretsDecrypt`, `make secretsEncrypt`, and `make secretsClean`, backed by `extras/secrets/tools/`. Only use those with **your own authorized keys** after examining the scripts; an upstream sample key or encrypted fixture is not a production secret.

Set `SOPS_AGE_KEY_FILE` to the path of your own securely stored age private key only when authorized secret operations are needed. Never echo private keys or decrypted environment contents, and avoid storing secrets in CI logs or public build artifacts.

**Release readiness:** hosted Android/iOS builds are compile-only. Before creating a signed distributable, separately verify signing identities, provisioning, keystore configuration and the release pipeline. See [CI and publication](CI.md).

## Documentation ownership

This page is the canonical human-facing guide for app customization and Android signing setup. Keep the executable setup code in `project_setup/` and secret tooling in `extras/secrets/tools/`; update this page rather than adding README files beside those tools.

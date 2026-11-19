# Small, cross-platform developer commands. CI is defined in .github/workflows.
.PHONY: setup install gen locale watch clean format analyze test check integration_test build-web build-web-wasm

setup: ## Customize app icon, splash and package identity interactively.
	@cd project_setup && fvm dart pub get
	@fvm dart ./project_setup/lib/main.dart

install: ## Install the pinned Flutter SDK and resolve packages.
	@dart pub global activate fvm
	@fvm install
	@fvm flutter pub get

gen: locale ## Regenerate source and localization.
	@fvm dart run build_runner build --delete-conflicting-outputs

locale:
	@fvm flutter gen-l10n --arb-dir assets/localization --template-arb-file app_en.arb --output-localization-file app_localizations.gen.dart --output-dir lib/assets

watch:
	@fvm dart run build_runner watch --delete-conflicting-outputs

clean:
	@fvm flutter clean
	@fvm flutter pub get
	@$(MAKE) gen

format:
	@fvm dart format lib test integration_test tool

analyze:
	@fvm flutter analyze

test:
	@fvm flutter test

check: analyze test ## Run local static analysis and tests.

integration_test:
	@patrol test --flavor develop

build-web:
	@fvm flutter build web -t lib/main_production.dart

build-web-wasm:
	@fvm flutter build web --wasm -t lib/main_production.dart

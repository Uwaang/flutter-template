import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app.dart';
import 'package:flutter_app/app/configuration/configuration.dart';
import 'package:flutter_app/app/setup/app_platform.dart';
import 'package:flutter_app/app/setup/flavor.dart';
import 'package:flutter_app/app/theme/custom_system_bars_theme.dart';
import 'package:flutter_app/common/provider/theme_mode_provider.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupApp({required Flavor flavor}) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  // Force app orientation to portrait and landscape.
  // This must be also forced in info.plist file for iOS, under [UISupportedInterfaceOrientations].
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure Flavor
  await Configuration.setup(flavor: flavor);

  // Load secrets from .env file and override with specific flavor file
  await dotenv.load(
    overrideWithFiles: switch (flavor) {
      Flavor.staging => ['.env-staging'],
      Flavor.develop => ['.env-development'],
      Flavor.production => ['.env-production'],
    },
  );

  // Supabase Auth is the only built-in backend. Optional push/analytics/
  // crash reporting are deliberately not initialized by this template.
  await SupabaseService.initialize();

  // Web support
  await _setupWebPlatform();

  // Desktop support
  await _setupDesktopPlatform();

  // Setup Images Cache size
  PaintingBinding.instance.imageCache.maximumSize = 100; // Number of images to hold in cache
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // Equals to 200 MB of cache

  // Load Theme Mode from DB before starting app
  await providerContainer.read(themeModeProvider.future);

  // Setup reactive Edge-to-Edge support across all platforms
  await CustomSystemBarsTheme.setupSystemBarsTheme(providerContainer: providerContainer);
}

Future<void> _setupWebPlatform() async {
  if (AppPlatform.isWeb) {
    // GitHub Pages is static hosting without a route-to-index rewrite.
    // Hash routes keep the browser's HTTP request at the existing index.html
    // on refresh and direct navigation. Other hosts retain path-style URLs.
    const useHashRoutingForStaticHosting = bool.fromEnvironment('FLUTTER_TEMPLATE_PAGES_HASH_ROUTING');
    if (!useHashRoutingForStaticHosting) {
      usePathUrlStrategy();
    }
  }
}

Future<void> _setupDesktopPlatform() async {
  if (AppPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(400, 400));
    await windowManager.setSize(const Size(500, 950));
  }
}

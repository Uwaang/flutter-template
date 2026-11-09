import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/app.dart';
import 'package:flutter_app/app/configuration/configuration.dart';
import 'package:flutter_app/app/setup/app_platform.dart';
import 'package:flutter_app/app/setup/flavor.dart';
import 'package:flutter_app/app/setup/web_setup.dart';
import 'package:flutter_app/app/theme/custom_system_bars_theme.dart';
import 'package:flutter_app/common/provider/theme_mode_provider.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:freerasp/freerasp.dart';
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

  // Setup FreeRASP Security
  await _setupRASP(flavor: flavor);

  // Web support
  await _setupWebPlatform(flavor: flavor);

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

// TODO(strv): [FreeRASP] Configure correct package names and other values
Future<void> _setupRASP({required Flavor flavor}) async {
  // Only Mobile platforms are supported!
  if (!AppPlatform.isMobile) return;

  final config = TalsecConfig(
    isProd: flavor == Flavor.production && !kDebugMode,
    watcherMail: 'michal.urbanek@strv.com',

    /// For Android
    androidConfig: AndroidConfig(
      packageName: dotenv.get('APP_ID'),
      // signingCertHashes: list of hashes of the certificates of the keys which were used to sign the application.
      // At least one hash value must be provided. Hashes which are passed here must be encoded in Base64 form
      // https://github.com/talsec/Free-RASP-Community/wiki/Getting-your-signing-certificate-hash-of-app
      signingCertHashes: [
        dotenv.get('SIGNING_CERT_DEBUG_BASE64'), // Debug
        dotenv.get('SIGNING_CERT_RELEASE_BASE64'), // Release
        dotenv.get('SIGNING_CERT_GOOGLE_PLAY_BASE64'), // Google Play
      ],
    ),

    /// For iOS
    iosConfig: IOSConfig(
      bundleIds: [dotenv.get('APP_ID')],
      teamId: dotenv.get('APPLE_TEAM_ID'),
    ),
  );

  // Setting up callbacks
  final callback = ThreatCallback(
    onAppIntegrity: () => Flogger.w('App integrity'),
    onObfuscationIssues: () => Flogger.w('Obfuscation issues'),
    onDebug: () => Flogger.w('Debugging'),
    onDeviceBinding: () => Flogger.w('Device binding'),
    onDeviceID: () => Flogger.w('Device ID'),
    onHooks: () => Flogger.w('Hooks'),
    onPasscode: () => Flogger.w('Phone has no passcode set'),
    onPrivilegedAccess: () => Flogger.w('Privileged access'),
    onSecureHardwareNotAvailable: () => Flogger.w('Secure hardware not available'),
    onSimulator: () => Flogger.w('Simulator'),
    onUnofficialStore: () => Flogger.w('Unofficial store'),
  );

  //  Attach listener and Start freeRASP
  await Talsec.instance.attachListener(callback);
  await Talsec.instance.start(config);
}

Future<void> _setupWebPlatform({required Flavor flavor}) async {
  if (AppPlatform.isWeb) {
    // Use paths without /#/
    usePathUrlStrategy();

    // Setup the Web
    WebSetup.setup(flavor: flavor);
  }
}

Future<void> _setupDesktopPlatform() async {
  if (AppPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(400, 400));
    await windowManager.setSize(const Size(500, 950));
  }
}

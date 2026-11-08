import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/app.dart';
import 'package:flutter_app/app/setup/flavor.dart';
import 'package:flutter_app/app/setup/setup_app.dart';

void main() async {
  if (const bool.fromEnvironment('QA_STARTUP_TRACE')) {
    debugPrint('[QA_STARTUP] main begin');
  }
  await setupApp(flavor: Flavor.production);
  if (const bool.fromEnvironment('QA_STARTUP_TRACE')) {
    debugPrint('[QA_STARTUP] main after setup; runApp begin');
  }
  App.startApp();
}

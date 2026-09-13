import 'package:flutter_app/app/setup/flavor.dart';
import 'package:web/web.dart';

class WebSetup {
  WebSetup._();

  static void setup({required Flavor flavor}) {
    final script = document.createElement('script');

    switch (flavor) {
      case Flavor.develop:
        script.id = 'develop';
      case Flavor.staging:
        script.id = 'staging';
      case Flavor.production:
        script.id = 'production';
    }

    document.head?.append(script);
  }
}

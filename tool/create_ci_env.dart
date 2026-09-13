import 'dart:io';

const _ciEnv = '''
API_HOST_URL=https://example.invalid
APP_ID=com.example.flutter_template
APPLE_ID=000000000
APPLE_TEAM_ID=CI00000000
FIREBASE_WEB_API_KEY=ci-placeholder
FIREBASE_WEB_MESSAGING_SENDER_ID=000000000000
FIREBASE_WEB_APP_ID=1:000000000000:web:ci
FIREBASE_WEB_MEASUREMENT_ID=G-CI00000000
SIGNING_CERT_DEBUG_BASE64=Y2k=
SIGNING_CERT_RELEASE_BASE64=Y2k=
SIGNING_CERT_GOOGLE_PLAY_BASE64=Y2k=
VAPID_KEY=ci-placeholder
''';

const _envFiles = <String>[
  '.env',
  '.env-development',
  '.env-staging',
  '.env-production',
];

void main() {
  for (final path in _envFiles) {
    File(path).writeAsStringSync(_ciEnv);
  }

  stdout.writeln('Created non-secret placeholder environment files for CI.');
}

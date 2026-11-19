import 'dart:io';

// Non-secret placeholders for compile-only CI and public mock UI previews.
// Never embed a real project URL/key in public CI.
const _ciEnv = '''
SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=
SUPABASE_OAUTH_REDIRECT_URL=
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

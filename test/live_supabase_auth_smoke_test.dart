import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Explicitly opt-in live Auth smoke: creates one persistent anonymous Auth
/// user in a disposable Supabase test project. Never runs in normal CI.
///
/// This does not verify Flutter's on-device session persistence or UI; the
/// companion manual checklist in docs/SUPABASE_FIRST.md covers those.
void main() {
  final enabled = Platform.environment['RUN_SUPABASE_AUTH_SMOKE'] == '1';

  test(
    'live anonymous Auth session can be restored and locally signed out',
    () async {
      final url = Platform.environment['SUPABASE_URL']?.trim() ?? '';
      final key = Platform.environment['SUPABASE_PUBLISHABLE_KEY']?.trim() ?? '';
      if (!url.startsWith('https://') || key.isEmpty) {
        fail('Provide the disposable test project SUPABASE_URL and public publishable key.');
      }
      if (key.startsWith('sb_secret_') || key.startsWith('eyJ')) {
        fail('Use a public publishable key, never a secret or service-role key.');
      }

      final first = SupabaseClient(url, key);
      SupabaseClient? restored;
      try {
        final response = await first.auth.signInAnonymously().timeout(const Duration(seconds: 40));
        final user = response.user;
        expect(user, isNotNull);
        expect(user!.isAnonymous, isTrue);
        expect(first.auth.currentUser?.id, user.id);

        final refreshToken = response.session?.refreshToken ?? '';
        expect(refreshToken, isNotEmpty);

        // A fresh SDK client must be able to recover the same Auth user from
        // its persisted refresh token. A full app restart is checked manually.
        restored = SupabaseClient(url, key);
        final resumed = await restored.auth.setSession(refreshToken).timeout(const Duration(seconds: 40));
        expect(resumed.user?.id, user.id);
        expect(restored.auth.currentSession, isNotNull);

        await restored.auth.signOut().timeout(const Duration(seconds: 40));
        expect(restored.auth.currentSession, isNull);
        expect(restored.auth.currentUser, isNull);
      } finally {
        if (restored != null) {
          await restored.dispose();
        }
        await first.dispose();
      }
    },
    skip: enabled ? false : 'Live Auth smoke requires explicit opt-in.',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase is the default backend for this template.
///
/// For CI's first-screen smoke tests, the public URL and publishable key are
/// deliberately absent. In that mode the SDK is NOT initialized and no
/// backend-authenticated user is fabricated.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured => _initialized;

  static Future<void> initialize() async {
    final url = (dotenv.env['SUPABASE_URL'] ?? '').trim();
    final publishableKey = (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim();

    if (url.isEmpty && publishableKey.isEmpty) {
      return;
    }

    if (url.isEmpty || publishableKey.isEmpty) {
      throw StateError('SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be configured together.');
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null || parsed.scheme != 'https' || parsed.host.isEmpty) {
      throw FormatException('SUPABASE_URL must be an HTTPS URL.');
    }

    await Supabase.initialize(url: url, publishableKey: publishableKey);
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase is not configured. Provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.');
    }
    return Supabase.instance.client;
  }

  static String? get oauthRedirectUrl {
    final redirect = (dotenv.env['SUPABASE_OAUTH_REDIRECT_URL'] ?? '').trim();
    return redirect.isEmpty ? null : redirect;
  }
}

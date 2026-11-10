import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sign_in_with_google_use_case.g.dart';

@riverpod
Future<void> signInWithGoogleUseCase(Ref ref) async {
  // On native platforms the callback scheme must match the app's deep link
  // registration and Supabase Auth redirect allow list.
  final redirect = SupabaseService.oauthRedirectUrl;
  if (!kIsWeb && redirect == null) {
    throw StateError('SUPABASE_OAUTH_REDIRECT_URL is required for native OAuth sign-in.');
  }

  final launched = await SupabaseService.client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: kIsWeb ? null : redirect,
  );
  if (!launched) {
    throw StateError('Unable to open the Google OAuth browser.');
  }
  // Browser launch != sign-in. The UI listens to onAuthStateChange for success.
}

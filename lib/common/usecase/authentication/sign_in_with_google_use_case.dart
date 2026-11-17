import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/supabase/oauth_redirect_url.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sign_in_with_google_use_case.g.dart';

@riverpod
Future<void> signInWithGoogleUseCase(Ref ref) async {
  // On native platforms the callback scheme must match the app's deep link
  // registration and Supabase Auth redirect allow list.
  final redirect = resolveOAuthRedirectUrl(
    isWeb: kIsWeb,
    currentUri: Uri.base,
    nativeRedirectUrl: SupabaseService.oauthRedirectUrl,
  );

  final launched = await SupabaseService.client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: redirect,
    authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  );
  if (!launched) {
    throw StateError('Unable to open the Google OAuth browser.');
  }
  // Browser launch != sign-in. The UI listens to onAuthStateChange for success.
}
